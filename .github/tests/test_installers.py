"""Exercise both bootstraps with real local Git repositories and a tiny Etch fixture."""
import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
REAL_GIT = shutil.which('git')
WINDOWS = os.name == 'nt'
HOSTS = [shutil.which('pwsh.exe'), shutil.which('powershell.exe')] if WINDOWS else ['/bin/sh']
HOSTS = [h for h in HOSTS if h]


class InstallerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.fixture = tempfile.TemporaryDirectory(prefix='dotfiles installer fixtures ')
        cls.base = Path(cls.fixture.name)
        cls.env = dict(os.environ, GIT_CONFIG_NOSYSTEM='1', GIT_CONFIG_GLOBAL=os.devnull,
                       GIT_ALLOW_PROTOCOL='file', GIT_AUTHOR_NAME='Installer Test',
                       GIT_AUTHOR_EMAIL='test@example.invalid', GIT_COMMITTER_NAME='Installer Test',
                       GIT_COMMITTER_EMAIL='test@example.invalid', GIT_TERMINAL_PROMPT='0')
        cls.engine = cls.base / 'engine'
        cls.source = cls.base / 'source'
        for path in [cls.engine, cls.source]:
            path.mkdir()
            cls.git('init', str(path))
        (cls.engine / 'etch').write_text(
            'import json,os,sys\nfrom pathlib import Path\n'
            'Path(os.environ["MODULE_LOG"]).write_text(json.dumps(sys.argv[1:]))\n'
            'sys.exit(int(os.environ.get("MODULE_EXIT", "0")))\n')
        cls.git('-C', str(cls.engine), 'add', '.')
        cls.git('-C', str(cls.engine), 'commit', '-m', 'Fixture engine')
        cls.git('-C', str(cls.source), 'submodule', 'add', str(cls.engine), 'vendor/etch')
        (cls.source / 'README').write_text('Fixture checkout\n')
        cls.git('-C', str(cls.source), 'add', '.')
        cls.git('-C', str(cls.source), 'commit', '-m', 'Fixture dotfiles')

    @classmethod
    def tearDownClass(cls):
        cls.fixture.cleanup()

    @classmethod
    def git(cls, *args):
        return subprocess.run([REAL_GIT, *args], env=cls.env, check=True,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='dotfiles bootstrap test ')
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.bin = self.base / 'bin'
        self.bin.mkdir()
        self.destination = self.base / 'checkout with spaces'
        self.log = self.base / 'git.jsonl'
        self.module_log = self.base / 'module.json'
        helper = self.bin / 'git_helper.py'
        helper.write_text('''import json,os,subprocess,sys
from pathlib import Path
args=sys.argv[1:]
with open(os.environ['GIT_LOG'],'a') as log: log.write(json.dumps(args)+'\\n')
if args[0]=='clone' and os.environ.get('CLONE_EXIT'): sys.exit(int(os.environ['CLONE_EXIT']))
if 'submodule' in args and 'update' in args and os.environ.get('SUBMODULE_EXIT'): sys.exit(int(os.environ['SUBMODULE_EXIT']))
clone=args[0]=='clone'
if clone: args[args.index('https://github.com/rahul0705/dotfiles.git')]=os.environ['FIXTURE_SOURCE']
result=subprocess.run([os.environ['REAL_GIT'],*args])
if clone and result.returncode==0:
 result=subprocess.run([os.environ['REAL_GIT'],'-C',args[-1],'remote','set-url','origin','https://github.com/rahul0705/dotfiles.git'])
sys.exit(result.returncode)
''')
        if WINDOWS:
            (self.bin / 'git.cmd').write_text(f'@"{sys.executable}" "{helper}" %*\n@exit /b %errorlevel%\n')
        else:
            wrapper = self.bin / 'git'
            wrapper.write_text(f'#!/bin/sh\nexec {shlex.quote(sys.executable)} {shlex.quote(str(helper))} "$@"\n')
            wrapper.chmod(0o755)
        self.env = dict(self.__class__.env, PATH=str(self.bin) + os.pathsep + os.environ['PATH'],
                        DOTFILES_DIR=str(self.destination), REAL_GIT=REAL_GIT,
                        FIXTURE_SOURCE=str(self.source), GIT_LOG=str(self.log), MODULE_LOG=str(self.module_log))

    def run_installer(self, *args, env=None, expected=0):
        host = self.host
        if WINDOWS:
            harness = self.base / 'invoke.ps1'
            installer = str(ROOT / 'install.ps1').replace("'", "''")
            harness.write_text("$PSNativeCommandUseErrorActionPreference = $true\n"
                               + f"& '{installer}' @args\nexit $LASTEXITCODE\n")
            command = [host, '-NoProfile', '-File', str(harness)]
        else:
            command = [host, str(ROOT / 'install.sh')]
        result = subprocess.run([*command, *args], env=env or self.env, cwd=self.base,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=60)
        self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
        return result

    def calls(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()] if self.log.exists() else []

    def test_default_module_and_submodule(self):
        self.run_installer()
        self.assertTrue((self.destination / 'vendor/etch/etch').is_file())
        self.assertEqual(json.loads(self.module_log.read_text()), ['apply', 'etch', '--repo', str(self.destination)])

    def test_override(self):
        self.run_installer('--module', 'git')
        self.assertEqual(json.loads(self.module_log.read_text())[1], 'git')

    def test_clone_only_precedence(self):
        for args in [('--no-module', '--module', 'git'), ('--module', 'git', '--no-module')]:
            self.env['DOTFILES_DIR'] = str(self.destination) + str(len(self.calls()))
            self.run_installer(*args)
            self.assertFalse(self.module_log.exists())

    def test_existing_checkout_is_strict_noop(self):
        self.run_installer('--no-module')
        (self.destination / 'README').write_text('User changes\n')
        self.log.unlink()
        unavailable = self.bin / ('python.cmd' if WINDOWS else 'python3')
        unavailable.write_text('@exit /b 127\n' if WINDOWS else '#!/bin/sh\nexit 127\n')
        unavailable.chmod(0o755)
        self.run_installer('--module', 'git')
        self.assertEqual((self.destination / 'README').read_text(), 'User changes\n')
        self.assertFalse(self.module_log.exists())
        self.assertTrue(all('clone' not in c and 'submodule' not in c and 'pull' not in c for c in self.calls()))

    def test_unrelated_occupied_directory(self):
        self.destination.mkdir()
        sentinel = self.destination / 'user-data'
        sentinel.write_text('Keep me')
        self.run_installer(expected=1)
        self.assertEqual(sentinel.read_text(), 'Keep me')
        self.assertFalse(self.calls())

    def test_unrelated_repository(self):
        self.destination.mkdir()
        self.git('init', str(self.destination))
        self.git('-C', str(self.destination), 'remote', 'add', 'origin', 'https://example.invalid/other.git')
        self.run_installer(expected=1)
        self.assertFalse(any(c[0] == 'clone' for c in self.calls()))

    def test_invalid_arguments(self):
        for args in [('--unknown',), ('--module',), ('--module', ''), ('--module', '--help')]:
            self.run_installer(*args, expected=2)
        self.assertFalse(self.destination.exists())
        self.assertFalse(self.calls())

    def test_help(self):
        self.run_installer('--help')
        self.assertFalse(self.calls())

    def test_missing_git(self):
        empty = self.base / 'empty'
        empty.mkdir()
        env = dict(self.env, PATH=str(empty))
        result = self.run_installer(env=env, expected=127)
        self.assertIn('Git is required', result.stderr)

    def test_python_unavailable_and_clone_only(self):
        name = 'python.cmd' if WINDOWS else 'python3'
        unavailable = self.bin / name
        unavailable.write_text('@exit /b 127\n' if WINDOWS else '#!/bin/sh\nexit 127\n')
        unavailable.chmod(0o755)
        self.run_installer(expected=127)
        self.assertFalse(self.destination.exists())
        self.run_installer('--no-module')
        self.assertTrue((self.destination / 'vendor/etch/etch').exists())
        self.assertFalse(self.module_log.exists())

    def test_repository_without_origin(self):
        self.destination.mkdir()
        self.git('init', str(self.destination))
        self.run_installer(expected=1)

    def test_clone_failure(self):
        self.run_installer(env=dict(self.env, CLONE_EXIT='41'), expected=41)
        self.assertFalse(self.destination.exists())

    def test_submodule_failure(self):
        self.run_installer(env=dict(self.env, SUBMODULE_EXIT='43'), expected=43)
        self.assertTrue(self.destination.exists())
        self.assertFalse(self.module_log.exists())

    def test_module_failure(self):
        self.run_installer(env=dict(self.env, MODULE_EXIT='47'), expected=47)
        self.assertTrue(self.destination.exists())


# Run the same behavioral contract under sh or both Windows PowerShell hosts.
for index, host in enumerate(HOSTS):
    globals()[f'InstallerHost{index}Tests'] = type(f'InstallerHost{index}Tests', (InstallerTests,), {'host': host})
del InstallerTests

if __name__ == '__main__':
    unittest.main()

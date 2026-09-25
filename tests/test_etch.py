"""Run the checked-in Git migration with a temporary consumer and home."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class GitMigrationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.repo = self.root / 'consumer'
        self.home = self.root / 'home'
        self.repo.mkdir()
        self.home.mkdir()
        for name in ('etch', 'defaults.conf'):
            shutil.copy2(ROOT / name, self.repo / name)
        for name in ('modules/git', 'profiles'):
            shutil.copytree(ROOT / name, self.repo / name)
        (self.repo / 'vendor').mkdir()
        # Use the actual pinned engine and plugins; no package installation.
        (self.repo / 'vendor/etch').symlink_to(ROOT / 'vendor/etch')
        self.env = dict(os.environ, HOME=str(self.home), PYTHONPATH='')

    def cli(self, *args):
        result = subprocess.run(
            [str(self.repo / 'etch'), *args], cwd=self.root,
            env=self.env, text=True, capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result.stdout

    def test_preview_apply_and_repeat(self):
        self.cli()
        plan = self.cli('plan', '--profile', 'developer', '-v')
        self.assertIn('CHANGE', plan)
        self.assertEqual(list(self.home.iterdir()), [])
        self.assertFalse((self.repo / '.etch').exists())
        doctor = self.cli('doctor', '--profile', 'developer')
        self.assertIn('etch-homebrew', doctor)
        self.assertIn('etch-vscode', doctor)
        self.cli('apply', '--profile', 'developer')
        for name in ('gitconfig', 'gitignore_global', 'gitmessage'):
            destination = self.home / ('.' + name)
            self.assertTrue(destination.is_symlink())
            self.assertEqual(destination.resolve(), self.repo / 'modules/git/files' / name)
        second = self.cli('apply', '--profile', 'developer')
        self.assertNotIn('CHANGED', second)
        self.assertIn('SKIPPED', second)

    def test_existing_file_is_preserved(self):
        existing = self.home / '.gitconfig'
        existing.write_text('[user]\n    name = Keep me\n')
        result = subprocess.run(
            [str(self.repo / 'etch'), 'apply', 'git'], cwd=self.root,
            env=self.env, text=True, capture_output=True,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(existing.read_text(), '[user]\n    name = Keep me\n')
        self.assertEqual(list(self.home.iterdir()), [existing])


if __name__ == '__main__':
    unittest.main()

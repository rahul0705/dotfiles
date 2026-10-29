"""Verify non-destructive profile integration under both Windows PowerShell hosts."""
import codecs
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
HOSTS = [shutil.which(name) for name in ("powershell.exe", "pwsh.exe")]
HOSTS = [host for host in HOSTS if host]


@unittest.skipUnless(os.name == "nt" and HOSTS, "Windows PowerShell required")
class PowerShellProfilesTests(unittest.TestCase):
    def test_preserve_encoding_content_and_repeat_without_duplicates(self):
        for host in HOSTS:
            with self.subTest(host=host), tempfile.TemporaryDirectory() as temporary:
                home = Path(temporary)
                documents = home / "redirected documents"
                legacy = documents / "WindowsPowerShell" / "profile.ps1"
                legacy.parent.mkdir(parents=True)
                original = codecs.BOM_UTF16_LE + "# Existing preferences: café".encode("utf-16-le")
                legacy.write_bytes(original)
                modern = documents / "PowerShell" / "profile.ps1"
                env = dict(os.environ, USERPROFILE=str(home))
                command = [host, "-NoProfile", "-NonInteractive", "-File",
                           str(ROOT / "modules/powershell/install-profiles.ps1"),
                           "-DocumentsDirectory", str(documents)]
                subprocess.run(command, env=env, check=True, capture_output=True)
                self.assertTrue(legacy.read_bytes().startswith(original))
                self.assertTrue(modern.is_file())
                first = [p.read_bytes() for p in (legacy, modern)]
                subprocess.run(command, env=env, check=True, capture_output=True)
                self.assertEqual(first, [p.read_bytes() for p in (legacy, modern)])
                for profile, encoding in ((legacy, "utf-16"), (modern, "utf-8-sig")):
                    self.assertEqual(profile.read_text(encoding=encoding).count(".config\\powershell\\profile.ps1"), 1)
                self.assertTrue((home / ".local/state/powershell/profiles-installed").is_file())


if __name__ == "__main__":
    unittest.main()

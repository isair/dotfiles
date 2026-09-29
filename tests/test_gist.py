import base64
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
import gist


class GistTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.profiles = Path(self.temp.name) / "profiles"
        self.profiles.mkdir()
        root_patch = patch.object(gist, "PROFILES_ROOT", self.profiles)
        root_patch.start()
        self.addCleanup(root_patch.stop)

    def payload(self, files, profile="personal"):
        return json.dumps({
            "format": "isair-dotfiles-profile", "version": 1, "profile": profile,
            "files": {name: base64.b64encode(content).decode("ascii") for name, content in files.items()},
        })

    def test_round_trip_preserves_nested_and_binary_files_and_skips_secure(self):
        source = self.profiles / "personal"
        (source / "configurations" / "config" / "nvim").mkdir(parents=True)
        (source / "configurations" / "config" / "nvim" / "init.lua").write_bytes(b"hello\r\n")
        (source / "packages").mkdir()
        (source / "packages" / "python.txt").write_bytes(b"\x00\xff")
        (source / "secure").mkdir()
        (source / "secure" / "key").write_text("secret")
        captured = {}

        def fake_gh(*args, input_text=None):
            captured["payload"] = input_text
            return "https://gist.github.com/" + "a" * 32 + "\n"

        with patch.object(gist, "run_gh", side_effect=fake_gh):
            self.assertIn("gist.github.com", gist.export_profile("personal"))
        self.assertNotIn("secure", captured["payload"])
        self.assertEqual(gist.decode_profile(captured["payload"])[1]["packages/python.txt"], b"\x00\xff")

        with patch.object(gist, "run_gh", return_value=captured["payload"]):
            target, previous = gist.restore_profile("a" * 32, "copy")
        self.assertIsNone(previous)
        self.assertEqual((target / "configurations" / "config" / "nvim" / "init.lua").read_bytes(), b"hello\r\n")
        self.assertEqual((target / "packages" / "python.txt").read_bytes(), b"\x00\xff")

    def test_restore_rejects_path_traversal_before_writing(self):
        for path in ("../escape", "packages/../../escape", "packages\\escape", "secure/key", "/absolute", "packages/CON"):
            with self.subTest(path=path):
                with patch.object(gist, "run_gh", return_value=self.payload({path: b"bad"})):
                    with self.assertRaises(gist.ProfileError):
                        gist.restore_profile("a" * 32)
                self.assertFalse((self.profiles / "personal").exists())

    def test_restore_refuses_existing_profile_then_preserves_it_on_replace(self):
        source = self.profiles / "personal"
        source.mkdir()
        (source / "old.txt").write_text("old")
        with patch.object(gist, "run_gh", return_value=self.payload({"packages/new.txt": b"new"})):
            with self.assertRaisesRegex(gist.ProfileError, "already exists"):
                gist.restore_profile("a" * 32)
            target, previous = gist.restore_profile("a" * 32, replace=True)
        self.assertEqual((target / "packages" / "new.txt").read_text(), "new")
        self.assertEqual((previous / "old.txt").read_text(), "old")

    def test_export_materialises_shared_symlink_and_rejects_external_link(self):
        source = self.profiles / "personal" / "configurations"
        source.mkdir(parents=True)
        shared = self.profiles / "shared"
        shared.mkdir()
        (shared / "vimrc").write_bytes(b"shared content")
        (source / "vimrc").symlink_to(shared / "vimrc")
        captured = {}
        with patch.object(gist, "run_gh", side_effect=lambda *args, **kwargs: captured.setdefault("payload", kwargs["input_text"])):
            gist.export_profile("personal")
        self.assertEqual(gist.decode_profile(captured["payload"])[1]["configurations/vimrc"], b"shared content")

        (source / "linked").symlink_to(Path(self.temp.name) / "secret")
        with self.assertRaisesRegex(gist.ProfileError, "symlink"):
            gist.export_profile("personal")
        with self.assertRaisesRegex(gist.ProfileError, "Invalid profile"):
            gist.export_profile("../outside")

    def test_restore_rejects_invalid_content_and_gist_identifier(self):
        with self.assertRaises(gist.ProfileError):
            gist.gist_id("https://gist.github.com.evil.example/" + "a" * 32)
        with self.assertRaises(gist.ProfileError):
            gist.decode_profile('{"format":"isair-dotfiles-profile","version":1,"profile":1,"files":{}}')
        with self.assertRaises(gist.ProfileError):
            gist.decode_profile('{"format":"isair-dotfiles-profile","version":1,"profile":"ok","files":{"packages/x":"not base64"}}')


if __name__ == "__main__":
    unittest.main()

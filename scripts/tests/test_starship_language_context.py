"""Regression tests for project discovery in the Starship language helper."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "starship-language-context"


class LanguageContextTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.env = dict(os.environ)
        self.env.pop("IN_NIX_SHELL", None)

    def check(self, directory):
        return subprocess.run(
            ["/bin/sh", str(SCRIPT), "--check"],
            cwd=directory, env=self.env, capture_output=True, text=True, timeout=5,
        )

    def test_source_files_without_manifest(self):
        for filename in ("init.lua", "main.py", "main.rs", "main.go", "variables.tf", "main.zig"):
            with self.subTest(filename=filename):
                directory = self.root / Path(filename).suffix[1:]
                directory.mkdir()
                (directory / filename).touch()
                result = self.check(directory)
                self.assertEqual(result.returncode, 0, result.stderr)

    def test_empty_directory_has_no_language(self):
        self.assertEqual(self.check(self.root).returncode, 1)

    def test_nested_directory_uses_parent_manifest(self):
        (self.root / "package.json").write_text("{}")
        child = self.root / "src" / "nested"
        child.mkdir(parents=True)
        self.assertEqual(self.check(child).returncode, 0)

    def test_render_lua_without_manifest(self):
        (self.root / "init.lua").touch()
        result = subprocess.run(
            ["/bin/sh", str(SCRIPT)], cwd=self.root, env=self.env,
            capture_output=True, text=True, timeout=5,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("", result.stdout)


if __name__ == "__main__":
    unittest.main()

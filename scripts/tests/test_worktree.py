"""Run with: python3 -m unittest discover -s scripts/tests -v"""
import importlib.machinery
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parents[1] / "worktree"
loader = importlib.machinery.SourceFileLoader("worktree", str(SCRIPT))
spec = importlib.util.spec_from_loader(loader.name, loader)
wt = importlib.util.module_from_spec(spec)
loader.exec_module(wt)


class WorktreeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="worktree-tests-")
        self.addCleanup(self.temp.cleanup)
        self.repo = Path(self.temp.name) / "repo with spaces"
        self.env = patch.dict(os.environ, {"GIT_CONFIG_GLOBAL": os.devnull, "GIT_CONFIG_NOSYSTEM": "1"})
        self.env.start()
        self.addCleanup(self.env.stop)
        wt.git("init", "-b", "main", str(self.repo))
        wt.git("-c", "user.name=Test", "-c", "user.email=test@example.invalid",
               "commit", "--allow-empty", "-m", "initial", cwd=self.repo)

    def test_new_branch_is_sibling_and_original_head_unchanged(self):
        before = wt.git("rev-parse", "HEAD", cwd=self.repo)
        with patch.object(wt, "open_worktree") as opened:
            wt.create(self.repo, "feature/login", "HEAD")
        records = wt.worktrees(self.repo)
        self.assertEqual(len(records), 2)
        target = Path(records[1]["worktree"])
        self.assertNotIn(self.repo.resolve(), target.parents)
        self.assertEqual(wt.branch_label(records[1]), "feature/login")
        self.assertEqual(wt.identity(self.repo), wt.identity(target))
        self.assertEqual(wt.git("rev-parse", "HEAD", cwd=self.repo), before)
        opened.assert_called_once()
        with patch.object(wt, "open_worktree") as reopened:
            wt.create(self.repo, "feature/login", "HEAD")
        self.assertEqual(len(wt.worktrees(self.repo)), 2)
        reopened.assert_called_once()

    def test_existing_branch_and_invalid_base(self):
        wt.git("branch", "existing", cwd=self.repo)
        with patch.object(wt, "open_worktree"):
            wt.create(self.repo, "existing")
        with self.assertRaises(subprocess.CalledProcessError):
            wt.create(self.repo, "new-branch", "missing-ref")
        self.assertEqual(len(wt.worktrees(self.repo)), 2)

    def test_invalid_names_do_not_create_worktrees(self):
        for name in ("--force", "../escape", "feature/../../escape"):
            with self.subTest(name=name), self.assertRaises((ValueError, subprocess.CalledProcessError)):
                wt.create(self.repo, name, "HEAD")
        self.assertEqual(len(wt.worktrees(self.repo)), 1)

    def test_nested_detached_worktree_and_floating_picker(self):
        nested = self.repo / "nested worktree"
        wt.git("worktree", "add", "--detach", str(nested), cwd=self.repo)
        records = wt.worktrees(self.repo)
        self.assertTrue(wt.branch_label(records[1]).startswith("detached@"))
        self.assertEqual(wt.owner(nested / "src", records), str(nested.resolve()))
        panes = [
            {"is_floating": True, "pane_cwd": str(nested), "tab_id": 1},
            {"exited": True, "pane_cwd": str(nested), "tab_id": 2},
            {"pane_cwd": str(nested / "src"), "tab_id": 7},
        ]
        with patch.object(wt, "run", return_value=json.dumps(panes)):
            self.assertEqual(wt.tabs_for_worktrees(records)[str(nested.resolve())], 7)

    def test_open_reuses_stable_tab_id(self):
        records = wt.worktrees(self.repo)
        with patch.object(wt, "tabs_for_worktrees", return_value={records[0]["worktree"]: 42}), \
                patch.object(wt, "run") as command:
            wt.open_worktree(records[0], records)
        command.assert_called_once_with(["zellij", "action", "go-to-tab-by-id", "42"])

    def test_project_clears_nested_session_environment(self):
        with patch.dict(os.environ, {"ZELLIJ": "0", "ZELLIJ_SESSION_NAME": "other", "NVIM": "socket"}), \
                patch.object(wt.os, "chdir"), patch.object(wt.os, "execvpe") as execute:
            wt.project(self.repo)
        program, args, env = execute.call_args.args
        self.assertEqual(program, "zellij")
        self.assertIn("attach", args)
        self.assertIn("--create", args)
        self.assertNotIn("ZELLIJ", env)
        self.assertNotIn("NVIM", env)
        self.assertEqual(env["DOTFILES_PROJECT_ROOT"], str(self.repo.resolve()))


if __name__ == "__main__":
    unittest.main()

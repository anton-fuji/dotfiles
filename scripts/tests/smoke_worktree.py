"""Opt-in integration check using an isolated, short-lived Zellij session."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import time
import uuid
from unittest.mock import patch

from test_worktree import wt


def main():
    with tempfile.TemporaryDirectory(prefix="worktree-smoke-", dir="/tmp") as temp:
        root = Path(temp)
        session = "dotfiles-test-" + uuid.uuid4().hex[:12]
        env = {k: v for k, v in os.environ.items() if not k.startswith("ZELLIJ")}
        env.update({
            "ZELLIJ_SOCKET_DIR": str(root / "sockets"),
            "XDG_CACHE_HOME": str(root / "cache"),
            "XDG_STATE_HOME": str(root / "state"),
            "GIT_CONFIG_GLOBAL": os.devnull,
            "GIT_CONFIG_NOSYSTEM": "1",
        })
        prefix = ["zellij", "--data-dir", str(root / "data"), "--config", str(wt.CONFIG / "zellij/config.kdl")]

        def zellij(*args):
            return subprocess.run([*prefix, "--session", session, *args], env=env,
                                  check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                  text=True, timeout=15).stdout

        with patch.dict(os.environ, env, clear=True):
            repo = root / "repo with spaces"
            wt.git("init", "-b", "main", str(repo))
            wt.git("-c", "user.name=Test", "-c", "user.email=test@example.invalid",
                   "commit", "--allow-empty", "-m", "initial", cwd=repo)
            # Exercise the real layout, with a clean editor to avoid user plugins/state.
            layout = (wt.CONFIG / "zellij/layouts/worktree.kdl").read_text().replace(
                'pane command="nvim"', 'pane command="nvim" { args "-u" "NONE" "-i" "NONE"; }')
            test_config = root / "config"
            layout_path = test_config / "zellij/layouts/worktree.kdl"
            layout_path.parent.mkdir(parents=True)
            layout_path.write_text(layout)
            real_run = wt.run

            def routed_run(args, cwd=None):
                if args[0] == "zellij":
                    return zellij(*args[1:])
                return real_run(args, cwd=cwd)

            started = False
            try:
                started = True
                subprocess.run([*prefix, "--layout-string", layout, "attach", "--create-background", session],
                               cwd=repo, env=env, check=True, timeout=15,
                               stdout=subprocess.DEVNULL, stderr=None)
                for _ in range(30):
                    panes = json.loads(zellij("action", "list-panes", "--json"))
                    if any(p.get("pane_cwd") for p in panes):
                        break
                    time.sleep(0.1)
                print("Pane metadata:", [{k: p.get(k) for k in ("tab_id", "pane_cwd", "is_floating", "exited")}
                                         for p in panes if not p.get("is_plugin")])
                with patch.object(wt, "run", routed_run), patch.object(wt, "CONFIG", test_config):
                    records = wt.worktrees(repo)
                    assert records[0]["worktree"] in wt.tabs_for_worktrees(records), panes
                    before = len(json.loads(zellij("action", "list-tabs", "--json")))
                    wt.open_worktree(records[0], records)
                    assert len(json.loads(zellij("action", "list-tabs", "--json"))) == before
                    wt.create(repo, "feature/test", "HEAD")
                    records = wt.worktrees(repo)
                    for _ in range(30):
                        if records[1]["worktree"] in wt.tabs_for_worktrees(records):
                            break
                        time.sleep(0.1)
                    assert records[1]["worktree"] in wt.tabs_for_worktrees(records)
                    wt.create(repo, "feature/test", "HEAD")
                    assert len(json.loads(zellij("action", "list-tabs", "--json"))) == before + 1
                    wt.open_worktree(records[0], records)
                print("PASS: real Zellij tab reuse, creation, repeated selection, and return navigation")
            finally:
                if started:
                    zellij("kill-session", session)


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        print(error.stderr.decode() if isinstance(error.stderr, bytes) else error.stderr)
        raise

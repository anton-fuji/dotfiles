package main

import (
	"bufio"
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
	"syscall"
)

type worktree struct {
	path, branch, head string
	bare, prunable     bool
}

var inputReader = bufio.NewReader(os.Stdin)

func (w worktree) label() string {
	if name := strings.TrimPrefix(w.branch, "refs/heads/"); name != "" {
		return name
	}
	if w.head == "" {
		return "detached@unknown"
	}
	if len(w.head) > 8 {
		return "detached@" + w.head[:8]
	}
	return "detached@" + w.head
}

func output(dir, name string, args ...string) ([]byte, error) {
	cmd := exec.Command(name, args...)
	cmd.Dir = dir
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	out, err := cmd.Output()
	if err != nil {
		if message := strings.TrimSpace(stderr.String()); message != "" {
			return nil, errors.New(message)
		}
		return nil, err
	}
	return out, nil
}

func git(dir string, args ...string) (string, error) {
	out, err := output(dir, "git", args...)
	return string(out), err
}

func worktrees(dir string) ([]worktree, error) {
	raw, err := git(dir, "worktree", "list", "--porcelain", "-z")
	if err != nil {
		return nil, err
	}
	var records []worktree
	var current worktree
	for _, field := range strings.Split(raw, "\x00") {
		if field == "" {
			if current.path != "" && !current.bare && !current.prunable {
				if info, err := os.Stat(current.path); err == nil && info.IsDir() {
					records = append(records, current)
				}
			}
			current = worktree{}
			continue
		}
		key, value, _ := strings.Cut(field, " ")
		switch key {
		case "worktree":
			current.path = value
		case "branch":
			current.branch = value
		case "HEAD":
			current.head = value
		case "bare":
			current.bare = true
		case "prunable":
			current.prunable = true
		}
	}
	return records, nil
}

// canonical follows existing symlinks and retains the suffix of a new worktree path.
func canonical(path string) (string, error) {
	path, err := filepath.Abs(path)
	if err != nil {
		return "", err
	}
	path = filepath.Clean(path)
	var suffix []string
	for {
		resolved, err := filepath.EvalSymlinks(path)
		if err == nil {
			for i := len(suffix) - 1; i >= 0; i-- {
				resolved = filepath.Join(resolved, suffix[i])
			}
			return resolved, nil
		}
		if !os.IsNotExist(err) {
			return "", err
		}
		parent := filepath.Dir(path)
		if parent == path {
			return "", err
		}
		suffix = append(suffix, filepath.Base(path))
		path = parent
	}
}

func identity(dir string) (string, error) {
	common, err := git(dir, "rev-parse", "--path-format=absolute", "--git-common-dir")
	if err != nil {
		return "", err
	}
	resolved, err := canonical(strings.TrimSpace(common))
	if err != nil {
		return "", err
	}
	sum := sha256.Sum256([]byte(resolved))
	return hex.EncodeToString(sum[:])[:10], nil
}

func descendant(path, root string) bool {
	rel, err := filepath.Rel(root, path)
	return err == nil && rel != "." && rel != ".." && !strings.HasPrefix(rel, ".."+string(os.PathSeparator))
}

func owner(cwd string, records []worktree) string {
	if cwd == "" {
		return ""
	}
	path, err := canonical(cwd)
	if err != nil {
		return ""
	}
	sorted := append([]worktree(nil), records...)
	sort.SliceStable(sorted, func(i, j int) bool { return len(sorted[i].path) > len(sorted[j].path) })
	for _, record := range sorted {
		root, err := canonical(record.path)
		if err == nil && (path == root || descendant(path, root)) {
			return record.path
		}
	}
	return ""
}

type pane struct {
	CWD      string          `json:"pane_cwd"`
	TabID    json.RawMessage `json:"tab_id"`
	Plugin   bool            `json:"is_plugin"`
	Floating bool            `json:"is_floating"`
	Exited   bool            `json:"exited"`
}

func tabsForWorktrees(records []worktree) (map[string]string, error) {
	raw, err := output("", "zellij", "action", "list-panes", "--json")
	if err != nil {
		return nil, err
	}
	var panes []pane
	if err := json.Unmarshal(raw, &panes); err != nil {
		return nil, err
	}
	tabs := make(map[string]string)
	for _, p := range panes {
		if p.Plugin || p.Floating || p.Exited || len(p.TabID) == 0 {
			continue
		}
		root := owner(p.CWD, records)
		if root == "" || tabs[root] != "" {
			continue
		}
		var id string
		if err := json.Unmarshal(p.TabID, &id); err != nil {
			id = string(p.TabID)
		}
		tabs[root] = id
	}
	return tabs, nil
}

func openWorktree(record worktree, records []worktree, configRoot string) error {
	tabs, err := tabsForWorktrees(records)
	if err != nil {
		return err
	}
	if id := tabs[record.path]; id != "" {
		_, err = output("", "zellij", "action", "go-to-tab-by-id", id)
	} else {
		_, err = output("", "zellij", "action", "new-tab", "--name", record.label(), "--cwd", record.path,
			"--layout", filepath.Join(configRoot, "zellij/layouts/worktree.kdl"))
	}
	return err
}

func withoutEnv(env []string, keys ...string) []string {
	result := make([]string, 0, len(env))
	for _, entry := range env {
		key, _, _ := strings.Cut(entry, "=")
		skip := false
		for _, excluded := range keys {
			if key == excluded {
				skip = true
				break
			}
		}
		if !skip {
			result = append(result, entry)
		}
	}
	return result
}

func pick(dir, configRoot string) error {
	records, err := worktrees(dir)
	if err != nil {
		return err
	}
	if len(records) == 0 {
		return errors.New("利用可能なworktreeがありません。")
	}
	tabs, err := tabsForWorktrees(records)
	if err != nil {
		return err
	}
	var input bytes.Buffer
	for i, r := range records {
		status := "    "
		if tabs[r.path] != "" {
			status = "open"
		}
		fmt.Fprintf(&input, "%d\t%s  %s  %s\x00", i, status, r.label(), r.path)
	}
	cmd := exec.Command("fzf", "--read0", "--print0", "--delimiter=\t", "--with-nth=2..",
		"--layout=reverse", "--border=rounded", "--prompt=Worktree > ",
		"--header=Enter: switch/open worktree · Esc: cancel", "--no-multi")
	cmd.Stdin = &input
	cmd.Stderr = os.Stderr
	cmd.Env = append(withoutEnv(os.Environ(), "FZF_DEFAULT_OPTS", "FZF_DEFAULT_OPTS_FILE"),
		"FZF_DEFAULT_OPTS=", "FZF_DEFAULT_OPTS_FILE=")
	raw, err := cmd.Output()
	if err != nil {
		var exit *exec.ExitError
		if errors.As(err, &exit) && (exit.ExitCode() == 1 || exit.ExitCode() == 130) {
			return nil
		}
		return err
	}
	indexText, _, ok := bytes.Cut(raw, []byte{'\t'})
	if !ok {
		return errors.New("fzfの選択結果を読み取れませんでした。")
	}
	index, err := strconv.Atoi(string(indexText))
	if err != nil || index < 0 || index >= len(records) {
		return errors.New("fzfの選択番号が不正です。")
	}
	return openWorktree(records[index], records, configRoot)
}

func prompt(message string) (string, error) {
	fmt.Print(message)
	line, err := inputReader.ReadString('\n')
	if errors.Is(err, io.EOF) {
		return strings.TrimSpace(line), nil
	}
	return strings.TrimSpace(line), err
}

func create(dir, configRoot, branch, base string) error {
	records, err := worktrees(dir)
	if err != nil {
		return err
	}
	if branch == "" {
		branch, err = prompt("新しい作業のブランチ名（空欄で中止）: ")
		if err != nil {
			return err
		}
	}
	if branch == "" {
		return nil
	}
	valid, err := git(dir, "check-ref-format", "--branch", branch)
	if strings.HasPrefix(branch, "-") || err != nil || strings.TrimSpace(valid) != branch {
		return errors.New("通常のブランチ名を指定してください。")
	}
	for _, r := range records {
		if r.branch == "refs/heads/"+branch {
			return openWorktree(r, records, configRoot)
		}
	}
	if len(records) == 0 {
		return errors.New("利用可能なworktreeがありません。")
	}
	main, err := canonical(records[0].path)
	if err != nil {
		return err
	}
	id, err := identity(dir)
	if err != nil {
		return err
	}
	directory := filepath.Join(filepath.Dir(main), ".worktrees", filepath.Base(main)+"-"+id)
	target := filepath.Join(directory, branch)
	dirResolved, err := canonical(directory)
	if err != nil {
		return err
	}
	targetResolved, err := canonical(target)
	if err != nil {
		return err
	}
	if !descendant(targetResolved, dirResolved) {
		return errors.New("worktree保存先の外を指すブランチ名です。")
	}
	if _, err := os.Lstat(target); err == nil {
		return fmt.Errorf("保存先がすでに存在します: %s", target)
	} else if !os.IsNotExist(err) {
		return err
	}
	check := exec.Command("git", "show-ref", "--verify", "--quiet", "refs/heads/"+branch)
	check.Dir = dir
	err = check.Run()
	exists := err == nil
	if err != nil {
		var exit *exec.ExitError
		if !errors.As(err, &exit) || exit.ExitCode() != 1 {
			return errors.New("ブランチの確認に失敗しました。")
		}
	}
	var args []string
	if exists {
		args = []string{"worktree", "add", target, branch}
	} else {
		if base == "" {
			base, err = prompt("分岐元 [HEAD（現在のコミット）]: ")
			if err != nil {
				return err
			}
		}
		if base == "" {
			base = "HEAD"
		}
		commit, err := git(dir, "rev-parse", "--verify", "--end-of-options", base+"^{commit}")
		if err != nil {
			return err
		}
		args = []string{"worktree", "add", "-b", branch, target, strings.TrimSpace(commit)}
	}
	if _, err := git(dir, args...); err != nil {
		return err
	}
	fmt.Println("作成しました:", target)
	updated, err := worktrees(dir)
	if err == nil {
		found := false
		for _, r := range updated {
			resolved, resolveErr := canonical(r.path)
			if resolveErr == nil && resolved == targetResolved {
				found = true
				err = openWorktree(r, updated, configRoot)
				break
			}
		}
		if !found {
			err = errors.New("作成したworktreeが一覧に見つかりません。")
		}
		if err == nil {
			return nil
		}
	}
	fmt.Fprintln(os.Stderr, "worktreeの作成は完了しています。タブ起動だけを再試行してください。")
	return err
}

func project(path string) error {
	records, err := worktrees(path)
	if err != nil {
		return err
	}
	if len(records) == 0 {
		return errors.New("利用可能なworktreeがありません。")
	}
	root, err := canonical(records[0].path)
	if err != nil {
		return err
	}
	id, err := identity(path)
	if err != nil {
		return err
	}
	name, _ := json.Marshal(records[0].label())
	layout := "layout {\n  tab name=" + string(name) + " {\n" +
		"    pane size=1 borderless=true { plugin location=\"zellij:tab-bar\"; }\n" +
		"    pane command=\"nvim\"\n  }\n}\n"
	env := make([]string, 0, len(os.Environ()))
	for _, entry := range os.Environ() {
		key, _, _ := strings.Cut(entry, "=")
		if !strings.HasPrefix(key, "ZELLIJ") && key != "NVIM" && key != "NVIM_LISTEN_ADDRESS" && key != "DOTFILES_PROJECT_ROOT" {
			env = append(env, entry)
		}
	}
	env = append(env, "DOTFILES_PROJECT_ROOT="+root)
	if err := os.Chdir(root); err != nil {
		return err
	}
	binary, err := exec.LookPath("zellij")
	if err != nil {
		return err
	}
	return syscall.Exec(binary, []string{"zellij", "--layout-string", layout, "attach", "--create", "p-" + id}, env)
}

func usage() error {
	fmt.Fprintln(os.Stderr, "usage: worktree pick | new [branch] [--base ref] | project <path>")
	return errors.New("引数を確認してください。")
}

func run() error {
	args := os.Args[1:]
	if len(args) > 0 && (args[0] == "-h" || args[0] == "--help") {
		fmt.Println("usage: worktree pick | new [branch] [--base ref] | project <path>")
		return nil
	}
	if len(args) == 0 {
		return usage()
	}
	action, branch, base, path := args[0], "", "", ""
	switch action {
	case "pick":
		if len(args) != 1 {
			return usage()
		}
	case "new":
		for i := 1; i < len(args); i++ {
			if args[i] == "--base" {
				i++
				if i >= len(args) || base != "" {
					return usage()
				}
				base = args[i]
			} else if branch == "" {
				branch = args[i]
			} else {
				return usage()
			}
		}
	case "project":
		if len(args) != 2 {
			return usage()
		}
		path = args[1]
	default:
		return usage()
	}
	programs := []string{"git", "zellij", "nvim"}
	if action == "pick" {
		programs = append(programs, "fzf")
	}
	for _, program := range programs {
		if _, err := exec.LookPath(program); err != nil {
			return fmt.Errorf("必要なコマンドが見つかりません: %s", program)
		}
	}
	if action == "project" {
		return project(path)
	}
	if os.Getenv("ZELLIJ") == "" {
		return errors.New("Zellij内で実行してください。WezTermのCmd+Shift+Pからプロジェクトを開けます。")
	}
	dir, err := os.Getwd()
	if err != nil {
		return err
	}
	if _, err := git(dir, "rev-parse", "--git-common-dir"); err != nil {
		if fallback := os.Getenv("DOTFILES_PROJECT_ROOT"); fallback != "" {
			dir = fallback
		}
	}
	configRoot := os.Getenv("DOTFILES_CONFIG_ROOT")
	if configRoot == "" {
		configRoot = filepath.Join(os.Getenv("HOME"), ".config")
	}
	if action == "pick" {
		return pick(dir, configRoot)
	}
	return create(dir, configRoot, branch, base)
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, "worktree:", err)
		if info, statErr := os.Stdin.Stat(); statErr == nil && info.Mode()&os.ModeCharDevice != 0 {
			fmt.Print("Enterで閉じる")
			var line string
			fmt.Scanln(&line)
		}
		os.Exit(1)
	}
}

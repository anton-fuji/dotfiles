package main

import (
	"encoding/json"
	"os"
	"os/exec"
	"path/filepath"
	"testing"
)

func TestToolPayload(t *testing.T) {
	dir := t.TempDir()
	artifact := filepath.Join(dir, "result.json")
	nested := `{"content":[{"type":"text","text":"{\"ansi\":\"frame\"}"}]}`
	if err := os.WriteFile(artifact, []byte(nested), 0600); err != nil {
		t.Fatal(err)
	}
	ref, _ := json.Marshal(map[string]any{"success": true, "inline": false, "artifact": map[string]string{"filePath": artifact}})
	cases := []struct {
		name      string
		data      []byte
		wantError bool
	}{
		{"inline", []byte(nested), false},
		{"artifact", ref, false},
		{"tool error", []byte(`{"isError":true,"content":[]}`), true},
		{"operation error", []byte(`{"success":false,"error":"failed"}`), true},
		{"empty content", []byte(`{"content":[]}`), true},
		{"invalid JSON", []byte(`{`), true},
	}
	for _, tt := range cases {
		t.Run(tt.name, func(t *testing.T) {
			got, err := toolPayload(tt.data, dir)
			if (err != nil) != tt.wantError {
				t.Fatalf("error=%v, expected error=%v", err, tt.wantError)
			}
			if !tt.wantError && string(got["ansi"]) != `"frame"` {
				t.Fatalf("unexpected payload: %s", got["ansi"])
			}
		})
	}
}

func TestArtifactMustStayWithinTemporaryProject(t *testing.T) {
	root, outside := t.TempDir(), t.TempDir()
	path := filepath.Join(outside, "outside.json")
	if err := os.WriteFile(path, []byte(`{}`), 0600); err != nil {
		t.Fatal(err)
	}
	if _, err := readArtifact(root, path); err == nil {
		t.Fatal("accepted an outside artifact")
	}
	link := filepath.Join(root, "link.json")
	if err := os.Symlink(path, link); err != nil {
		t.Fatal(err)
	}
	if _, err := readArtifact(root, link); err == nil {
		t.Fatal("accepted an outside symlink target")
	}
}

func TestOutputPreparationDoesNotPublishOnError(t *testing.T) {
	root := t.TempDir()
	path := filepath.Join(root, "existing.txt")
	if err := os.WriteFile(path, []byte("original"), 0600); err != nil {
		t.Fatal(err)
	}
	err := writeOutputs(root, map[string][]byte{"existing.txt": []byte("replacement"), "../outside.txt": []byte("outside")})
	if err == nil {
		t.Fatal("accepted a parent-directory output")
	}
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	if string(data) != "original" {
		t.Fatal("published output before all files were staged")
	}
	entries, err := os.ReadDir(root)
	if err != nil {
		t.Fatal(err)
	}
	if len(entries) != 1 {
		t.Fatal("staging directory was not removed")
	}
}

func TestFailedMCPExportPreservesFiles(t *testing.T) {
	server, err := exec.LookPath("false")
	if err != nil {
		t.Skip("false executable is unavailable")
	}
	root := t.TempDir()
	session := []byte(`{"animation":{"frames":[{"duration":100}]}}`)
	projectPath := filepath.Join(root, "gopher-splat.asciimtn")
	framePath := filepath.Join(root, "animation", "frame-01.ansi")
	if err := os.MkdirAll(filepath.Dir(framePath), 0755); err != nil {
		t.Fatal(err)
	}
	for path, data := range map[string][]byte{projectPath: session, framePath: []byte("original frame")} {
		if err := os.WriteFile(path, data, 0600); err != nil {
			t.Fatal(err)
		}
	}
	if err := run([]string{"export", "-dir", root, "-mcp-server", server}); err == nil {
		t.Fatal("export succeeded despite the MCP server exiting")
	}
	for path, want := range map[string]string{projectPath: string(session), framePath: "original frame"} {
		got, err := os.ReadFile(path)
		if err != nil || string(got) != want {
			t.Fatalf("export changed %s after failing: %v", filepath.Base(path), err)
		}
	}
}

// gopher-art builds the editable Gopher animation and exports it through ASCII Motion MCP.
package main

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"reflect"
	"sort"
	"strings"
	"time"
)

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, "gopher-art:", err)
		os.Exit(1)
	}
}

func run(args []string) error {
	mode := "all"
	if len(args) > 0 && len(args[0]) > 0 && args[0][0] != '-' {
		mode, args = args[0], args[1:]
	}
	flags := flag.NewFlagSet("gopher-art", flag.ContinueOnError)
	dir := flags.String("dir", ".", "directory containing Gopher source images and output files")
	server := flags.String("mcp-server", "", "optional installed ASCII Motion MCP executable (default: cached v3.0.1, then PATH)")
	flags.Usage = func() {
		fmt.Fprintln(flags.Output(), "Usage: gopher-art [all|build|export] [-dir path] [-mcp-server executable]")
		flags.PrintDefaults()
	}
	if err := flags.Parse(args); err != nil {
		if errors.Is(err, flag.ErrHelp) {
			return nil
		}
		return err
	}
	if flags.NArg() != 0 {
		return fmt.Errorf("unexpected argument %q", flags.Arg(0))
	}
	if mode != "all" && mode != "build" && mode != "export" {
		return fmt.Errorf("unknown command %q; use all, build or export", mode)
	}
	root, err := filepath.Abs(*dir)
	if err != nil {
		return err
	}
	info, err := os.Stat(root)
	if err != nil {
		return err
	}
	if !info.IsDir() {
		return fmt.Errorf("-dir must be a directory")
	}
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Minute)
	defer cancel()
	outputs := make(map[string][]byte)
	var session []byte
	if mode != "export" {
		art, err := loadArtwork(ctx, root)
		if err != nil {
			return err
		}
		outputs, err = projectOutputs(newProject(art))
		if err != nil {
			return err
		}
		session = outputs["gopher-splat.asciimtn"]
	} else {
		session, err = os.ReadFile(filepath.Join(root, "gopher-splat.asciimtn"))
		if err != nil {
			return err
		}
	}
	if mode != "build" {
		frames, err := exportANSI(ctx, session, *server)
		if err != nil {
			return err
		}
		for name, data := range frames {
			outputs[name] = data
		}
	}
	if err := writeOutputs(root, outputs); err != nil {
		return err
	}
	var p project
	if err := json.Unmarshal(session, &p); err != nil {
		return err
	}
	total := 0
	for _, f := range p.Animation.Frames {
		total += f.Duration
	}
	fmt.Printf("%s: %dx%d, %d frames, %d ms\n", mode, p.Canvas.Width, p.Canvas.Height, len(p.Animation.Frames), total)
	return nil
}

// Stage every generated file before publishing. Preserve existing JSON formatting
// when its content is unchanged, so a language migration does not rewrite the art.
func writeOutputs(root string, outputs map[string][]byte) error {
	stage, err := os.MkdirTemp(root, ".gopher-art-")
	if err != nil {
		return err
	}
	defer os.RemoveAll(stage)
	names := make([]string, 0, len(outputs))
	for name, data := range outputs {
		if filepath.IsAbs(name) || filepath.Clean(name) != name || name == ".." || strings.HasPrefix(name, ".."+string(filepath.Separator)) {
			return fmt.Errorf("invalid output path %q", name)
		}
		target := filepath.Join(root, name)
		old, readErr := os.ReadFile(target)
		if readErr == nil && (bytes.Equal(old, data) || (name == "gopher-splat.asciimtn" && sameJSON(old, data))) {
			continue
		}
		if readErr != nil && !errors.Is(readErr, os.ErrNotExist) {
			return readErr
		}
		path := filepath.Join(stage, name)
		if err := os.MkdirAll(filepath.Dir(path), 0755); err != nil {
			return err
		}
		if err := os.WriteFile(path, data, 0644); err != nil {
			return err
		}
		names = append(names, name)
	}
	sort.Strings(names)
	for _, name := range names {
		target := filepath.Join(root, name)
		if err := os.MkdirAll(filepath.Dir(target), 0755); err != nil {
			return err
		}
		if err := os.Rename(filepath.Join(stage, name), target); err != nil {
			return err
		}
	}
	return nil
}

func sameJSON(a, b []byte) bool {
	var left, right any
	return json.Unmarshal(a, &left) == nil && json.Unmarshal(b, &right) == nil && reflect.DeepEqual(left, right)
}

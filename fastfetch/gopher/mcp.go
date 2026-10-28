package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

type mcpClient struct {
	cmd     *exec.Cmd
	stdin   io.WriteCloser
	encoder *json.Encoder
	decoder *json.Decoder
	id      int
}
type rpcResponse struct {
	ID     int             `json:"id"`
	Result json.RawMessage `json:"result"`
	Error  *struct {
		Code    int    `json:"code"`
		Message string `json:"message"`
	} `json:"error"`
}

func startMCP(ctx context.Context, dir, server string) (*mcpClient, error) {
	command, err := mcpCommand(server)
	if err != nil {
		return nil, err
	}
	command = append(command, "--project-dir", dir)
	cmd := exec.CommandContext(ctx, command[0], command[1:]...)
	cmd.Stderr = io.Discard
	stdin, err := cmd.StdinPipe()
	if err != nil {
		return nil, err
	}
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		stdin.Close()
		return nil, err
	}
	if err := cmd.Start(); err != nil {
		stdin.Close()
		stdout.Close()
		return nil, err
	}
	return &mcpClient{cmd: cmd, stdin: stdin, encoder: json.NewEncoder(stdin), decoder: json.NewDecoder(stdout)}, nil
}

func mcpCommand(server string) ([]string, error) {
	if server != "" {
		path, err := exec.LookPath(server)
		if err != nil {
			return nil, fmt.Errorf("MCP executable: %w", err)
		}
		return []string{path}, nil
	}
	// Reuse the explicitly installed version; never download a package at startup.
	home, err := os.UserHomeDir()
	if err == nil {
		packages, _ := filepath.Glob(filepath.Join(home, ".npm", "_npx", "*", "node_modules", "ascii-motion-mcp"))
		for _, dir := range packages {
			data, err := os.ReadFile(filepath.Join(dir, "package.json"))
			if err != nil {
				continue
			}
			var pkg struct {
				Version string `json:"version"`
			}
			if json.Unmarshal(data, &pkg) != nil || pkg.Version != "3.0.1" {
				continue
			}
			entry := filepath.Join(dir, "dist", "index.js")
			if _, err := os.Stat(entry); err != nil {
				continue
			}
			node, err := exec.LookPath("node")
			if err != nil {
				return nil, fmt.Errorf("cached ASCII Motion MCP requires node: %w", err)
			}
			return []string{node, entry}, nil
		}
	}
	if path, err := exec.LookPath("ascii-motion-mcp"); err == nil {
		return []string{path}, nil
	}
	return nil, fmt.Errorf("ASCII Motion MCP not found; install v3.0.1 with npm exec --yes --package=ascii-motion-mcp@3.0.1 -- ascii-motion-mcp --version, or pass -mcp-server")
}

func (c *mcpClient) close() {
	c.stdin.Close()
	c.cmd.Process.Kill()
	c.cmd.Wait()
}

func (c *mcpClient) call(method string, params any) (json.RawMessage, error) {
	c.id++
	if err := c.encoder.Encode(map[string]any{"jsonrpc": "2.0", "id": c.id, "method": method, "params": params}); err != nil {
		return nil, err
	}
	for {
		var response rpcResponse
		if err := c.decoder.Decode(&response); err != nil {
			return nil, fmt.Errorf("MCP %s response: %w", method, err)
		}
		if response.ID != c.id {
			continue
		} // Notifications have no request ID.
		if response.Error != nil {
			return nil, fmt.Errorf("MCP %s: %s (%d)", method, response.Error.Message, response.Error.Code)
		}
		return response.Result, nil
	}
}

func (c *mcpClient) tool(name string, args any, dir string) (map[string]json.RawMessage, error) {
	result, err := c.call("tools/call", map[string]any{"name": name, "arguments": args})
	if err != nil {
		return nil, err
	}
	payload, err := toolPayload(result, dir)
	if err != nil {
		return nil, fmt.Errorf("MCP %s: %w", name, err)
	}
	return payload, nil
}

// Large tool results may be stored as local artifacts by the MCP server.
func toolPayload(data []byte, dir string) (map[string]json.RawMessage, error) {
	for depth := 0; depth < 6; depth++ {
		var object map[string]json.RawMessage
		if err := json.Unmarshal(data, &object); err != nil {
			return nil, err
		}
		var toolError bool
		if raw, ok := object["isError"]; ok {
			if err := json.Unmarshal(raw, &toolError); err != nil {
				return nil, err
			}
		}
		if toolError {
			return nil, fmt.Errorf("tool returned an error")
		}
		if content, ok := object["content"]; ok {
			var blocks []struct {
				Type string `json:"type"`
				Text string `json:"text"`
			}
			if err := json.Unmarshal(content, &blocks); err != nil {
				return nil, err
			}
			if len(blocks) == 0 || blocks[0].Type != "text" {
				return nil, fmt.Errorf("expected a JSON text block")
			}
			data = []byte(blocks[0].Text)
			continue
		}
		var success bool
		if raw, ok := object["success"]; ok {
			if err := json.Unmarshal(raw, &success); err != nil {
				return nil, err
			}
			if !success {
				return nil, fmt.Errorf("operation failed: %s", object["error"])
			}
		}
		if artifact, ok := object["artifact"]; ok {
			var ref struct {
				FilePath string `json:"filePath"`
			}
			if err := json.Unmarshal(artifact, &ref); err != nil {
				return nil, err
			}
			var err error
			data, err = readArtifact(dir, ref.FilePath)
			if err != nil {
				return nil, err
			}
			continue
		}
		return object, nil
	}
	return nil, fmt.Errorf("too many nested tool results")
}

func readArtifact(root, path string) ([]byte, error) {
	root, err := filepath.EvalSymlinks(root)
	if err != nil {
		return nil, err
	}
	path, err = filepath.EvalSymlinks(path)
	if err != nil {
		return nil, err
	}
	rel, err := filepath.Rel(root, path)
	if err != nil || rel == ".." || strings.HasPrefix(rel, ".."+string(filepath.Separator)) || filepath.IsAbs(rel) {
		return nil, fmt.Errorf("MCP artifact is outside its temporary project directory")
	}
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer file.Close()
	const limit = 8 << 20
	data, err := io.ReadAll(io.LimitReader(file, limit+1))
	if err != nil {
		return nil, err
	}
	if len(data) > limit {
		return nil, fmt.Errorf("MCP artifact exceeds %d bytes", limit)
	}
	return data, nil
}

func exportANSI(ctx context.Context, session []byte, server string) (map[string][]byte, error) {
	var p project
	if err := json.Unmarshal(session, &p); err != nil {
		return nil, err
	}
	if len(p.Animation.Frames) == 0 {
		return nil, fmt.Errorf("project contains no animation frames")
	}
	work, err := os.MkdirTemp("", "gopher-art-export-")
	if err != nil {
		return nil, err
	}
	defer os.RemoveAll(work)
	if err := os.WriteFile(filepath.Join(work, "gopher-splat.asciimtn"), session, 0600); err != nil {
		return nil, err
	}
	client, err := startMCP(ctx, work, server)
	if err != nil {
		return nil, err
	}
	defer client.close()
	if _, err = client.call("initialize", map[string]any{"protocolVersion": "2024-11-05", "capabilities": map[string]any{}, "clientInfo": map[string]string{"name": "gopher-art", "version": "1"}}); err != nil {
		return nil, err
	}
	if err = client.encoder.Encode(map[string]any{"jsonrpc": "2.0", "method": "notifications/initialized"}); err != nil {
		return nil, err
	}
	loaded, err := client.tool("load_project", map[string]string{"filePath": "gopher-splat.asciimtn"}, work)
	if err != nil {
		return nil, err
	}
	if string(loaded["success"]) != "true" {
		return nil, fmt.Errorf("MCP did not load the project")
	}
	output := make(map[string][]byte, len(p.Animation.Frames))
	for i := range p.Animation.Frames {
		payload, err := client.tool("export_ansi", map[string]any{"frameIndex": i, "colorMode": "truecolor"}, work)
		if err != nil {
			return nil, err
		}
		var ansi string
		raw, ok := payload["ansi"]
		if !ok {
			return nil, fmt.Errorf("frame %d: MCP returned no ANSI data", i+1)
		}
		if err := json.Unmarshal(raw, &ansi); err != nil {
			return nil, err
		}
		// The exporter uses black for transparent cells. Reset to the terminal's
		// default background rather than painting a black rectangle.
		data := bytes.ReplaceAll([]byte(ansi), []byte("\x1b[48;2;0;0;0m"), []byte("\x1b[49m"))
		output[fmt.Sprintf("animation/frame-%02d.ansi", i+1)] = data
	}
	return output, nil
}

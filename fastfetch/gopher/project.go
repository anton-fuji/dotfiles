package main

import (
	"bytes"
	"context"
	"crypto/sha1"
	"encoding/json"
	"fmt"
	"math"
	"os/exec"
	"path/filepath"
	"strings"
)

const width, height = 48, 24

var palette = [...]string{"#FAFAFC", "#94CDDF", "#739BBA", "#C5B4AF", "#204866"}
var rgb = [...][3]int{{250, 250, 252}, {148, 205, 223}, {115, 155, 186}, {197, 180, 175}, {32, 72, 102}}
var dotBits = [4][2]uint{{0, 3}, {1, 4}, {2, 5}, {6, 7}}

type cell struct {
	Char       string `json:"char"`
	Color      string `json:"color"`
	Background string `json:"bgColor"`
}
type frame struct {
	ID       string          `json:"id"`
	Name     string          `json:"name"`
	Duration int             `json:"duration"`
	Data     map[string]cell `json:"data"`
}
type canvas struct {
	Width      int    `json:"width"`
	Height     int    `json:"height"`
	Background string `json:"canvasBackgroundColor"`
	ShowGrid   bool   `json:"showGrid"`
}
type animation struct {
	Frames            []frame `json:"frames"`
	CurrentFrameIndex int     `json:"currentFrameIndex"`
	FrameRate         int     `json:"frameRate"`
	Looping           bool    `json:"looping"`
}
type project struct {
	Version    string         `json:"version"`
	Name       string         `json:"name"`
	Canvas     canvas         `json:"canvas"`
	Animation  animation      `json:"animation"`
	Tools      map[string]any `json:"tools"`
	Typography map[string]any `json:"typography"`
}
type pose struct {
	scale, squash float64
	pressed       bool
	duration      int
}

func poses() []pose {
	result := []pose{{.40, 1, false, 100}}
	for i := 1; i <= 14; i++ {
		result = append(result, pose{.40 + .65*math.Pow(float64(i)/14, 1.6), 1, false, 45})
	}
	return append(result, []pose{
		{1.10, 1, false, 80},
		{1.12, .90, true, 60}, {1.20, .70, true, 70}, {1.24, .56, true, 180}, {1.18, .65, true, 80},
		{1.10, .85, true, 90}, {1.04, 1.05, true, 90}, {.98, 1.10, true, 90}, {1.02, .96, true, 90},
		{1, 1.02, true, 100}, {1, 1, true, 240},
	}...)
}

type artwork struct{ pressed, normal []byte }

func loadArtwork(ctx context.Context, dir string) (artwork, error) {
	pressed, err := imageBytes(ctx, []string{filepath.Join(dir, "source-reference.jpg"), "-crop", "930x940+0+1024", "+repage", "-resize", "192x192!", "-depth", "8", "rgb:-"}, 192*192*3)
	if err != nil {
		return artwork{}, err
	}
	normal, err := imageBytes(ctx, []string{filepath.Join(dir, "normal-pose.png"), "-trim", "+repage", "-resize", "180x180", "-background", "none", "-gravity", "center", "-extent", "192x192", "-depth", "8", "rgba:-"}, 192*192*4)
	if err != nil {
		return artwork{}, err
	}
	return artwork{pressed, normal}, nil
}

func imageBytes(ctx context.Context, args []string, want int) ([]byte, error) {
	cmd := exec.CommandContext(ctx, "magick", args...)
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	data, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("ImageMagick: %w: %s", err, strings.TrimSpace(stderr.String()))
	}
	if len(data) != want {
		return nil, fmt.Errorf("ImageMagick returned %d bytes, expected %d", len(data), want)
	}
	return data, nil
}

func (a artwork) sample(u, v float64, pressed bool) int {
	if u < 0 || u >= 1 || v < 0 || v >= 1 {
		return -1
	}
	x, y := int(u*192), int(v*192)
	var pixel [3]int
	if pressed {
		offset := (y*192 + x) * 3
		for c := range pixel {
			pixel[c] = int(a.pressed[offset+c])
		}
		if distance(pixel, [3]int{2, 53, 106}) < 700 {
			return -1
		}
	} else {
		offset := (y*192 + x) * 4
		if a.normal[offset+3] < 96 {
			return -1
		}
		for c := range pixel {
			pixel[c] = int(a.normal[offset+c])
		}
	}
	best := 0
	for c := 1; c < len(rgb); c++ {
		if distance(pixel, rgb[c]) < distance(pixel, rgb[best]) {
			best = c
		}
	}
	return best
}

func distance(a, b [3]int) int {
	total := 0
	for i := range a {
		d := a[i] - b[i]
		total += d * d
	}
	return total
}

func (a artwork) render(p pose) map[string]cell {
	var dots [height * 4][width * 2]int
	for py := range dots {
		for px := range dots[py] {
			u := (float64(px)+.5-width)/(float64(width)*86/48*p.scale) + .5
			v := (float64(py)+.5-height*2)/(float64(height)*88/24*p.scale*p.squash) + .5
			if p.pressed {
				u += .08 * math.Max(0, 1-p.squash) * math.Sin(v*math.Pi*2)
			}
			dots[py][px] = a.sample(u, v, p.pressed)
		}
	}
	cells := make(map[string]cell)
	for y := 0; y < height; y++ {
		for x := 0; x < width; x++ {
			var values [8]int
			for dy := 0; dy < 4; dy++ {
				for dx := 0; dx < 2; dx++ {
					values[dy*2+dx] = dots[y*4+dy][x*2+dx]
				}
			}
			if c, ok := brailleCell(values, p.pressed); ok {
				cells[fmt.Sprintf("%d,%d", x, y)] = c
			}
		}
	}
	return cells
}

func brailleCell(values [8]int, pressed bool) (cell, bool) {
	var counts [5]int
	for _, v := range values {
		if v >= 0 {
			counts[v]++
		}
	}
	color := 0
	for i := 1; i < len(counts); i++ {
		if counts[i] > counts[color] {
			color = i
		}
	}
	if counts[color] == 0 {
		return cell{}, false
	}
	// Preserve small pupils/contours as negative-space dots and white highlights.
	removeDark, whiteOnly := false, false
	if !pressed && counts[4] > 0 {
		if color != 4 {
			removeDark = true
		} else if counts[0] > 0 {
			color = 0
			whiteOnly = true
		}
	}
	mask := 0
	for dy := 0; dy < 4; dy++ {
		for dx := 0; dx < 2; dx++ {
			v := values[dy*2+dx]
			if v < 0 || (removeDark && v == 4) || (whiteOnly && v != 0) {
				continue
			}
			mask |= 1 << dotBits[dy][dx]
		}
	}
	return cell{string(rune(0x2800 + mask)), palette[color], "transparent"}, true
}

func newProject(a artwork) project {
	frames := make([]frame, 0, 26)
	for i, p := range poses() {
		phase := "Approach"
		switch {
		case i == 15:
			phase = "Contact"
		case i >= 16 && i < 20:
			phase = "Splat"
		case i >= 20:
			phase = "Settle"
		}
		frames = append(frames, frame{frameID(i), fmt.Sprintf("%s %02d", phase, i+1), p.duration, a.render(p)})
	}
	return project{
		Version: "1.0.0", Name: "Gopher — Hello, Glass!",
		Canvas:     canvas{width, height, "#000000", true},
		Animation:  animation{Frames: frames, FrameRate: 10},
		Tools:      map[string]any{"activeTool": "pencil", "selectedColor": palette[2], "selectedBgColor": "transparent", "selectedCharacter": "⣿", "paintBucketContiguous": true, "rectangleFilled": false},
		Typography: map[string]any{"fontSize": 16, "characterSpacing": 0, "lineSpacing": 0, "selectedFontId": "jetbrains-mono"},
	}
}

func frameID(index int) string {
	// UUID v5 using the URL namespace, matching the original project IDs.
	namespace := []byte{0x6b, 0xa7, 0xb8, 0x11, 0x9d, 0xad, 0x11, 0xd1, 0x80, 0xb4, 0x00, 0xc0, 0x4f, 0xd4, 0x30, 0xc8}
	sum := sha1.Sum(append(namespace, []byte(fmt.Sprintf("gopher-splat-%d", index))...))
	sum[6] = (sum[6] & 0x0f) | 0x50
	sum[8] = (sum[8] & 0x3f) | 0x80
	return fmt.Sprintf("%x-%x-%x-%x-%x", sum[:4], sum[4:6], sum[6:8], sum[8:10], sum[10:16])
}

func projectOutputs(p project) (map[string][]byte, error) {
	var encoded bytes.Buffer
	encoder := json.NewEncoder(&encoded)
	encoder.SetIndent("", "  ")
	encoder.SetEscapeHTML(false)
	if err := encoder.Encode(p); err != nil {
		return nil, err
	}
	var logo, timing strings.Builder
	last := p.Animation.Frames[len(p.Animation.Frames)-1]
	for y := 0; y < height; y++ {
		var row strings.Builder
		for x := 0; x < width; x++ {
			c, ok := last.Data[fmt.Sprintf("%d,%d", x, y)]
			if !ok {
				row.WriteByte(' ')
				continue
			}
			for i, color := range palette {
				if c.Color == color {
					fmt.Fprintf(&row, "$%d%s", i+1, c.Char)
					break
				}
			}
		}
		logo.WriteString(strings.TrimRight(row.String(), " \t\r\n"))
		logo.WriteByte('\n')
	}
	for i, f := range p.Animation.Frames {
		fmt.Fprintf(&timing, "frame-%02d.ansi\t%.3f\n", i+1, float64(f.Duration)/1000)
	}
	return map[string][]byte{"gopher-splat.asciimtn": encoded.Bytes(), "fastfetch-gopher.txt": []byte(logo.String()), "animation/timing.tsv": []byte(timing.String())}, nil
}

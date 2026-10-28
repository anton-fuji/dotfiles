package main

import (
	"strings"
	"testing"
)

func TestBrailleFacialDetails(t *testing.T) {
	tests := []struct {
		name    string
		values  [8]int
		pressed bool
		mask    int
		color   string
		exists  bool
	}{
		{"empty", [8]int{-1, -1, -1, -1, -1, -1, -1, -1}, false, 0, "", false},
		{"pupil negative space", [8]int{4, 0, 0, 0, 0, 0, 0, 0}, false, 0xfe, palette[0], true},
		{"white catchlight", [8]int{0, 4, 4, 4, 4, 4, 4, 4}, false, 1, palette[0], true},
		{"pressed pose keeps dots", [8]int{4, 0, 0, 0, 0, 0, 0, 0}, true, 0xff, palette[0], true},
		{"color tie picks first palette entry", [8]int{1, 0, -1, -1, -1, -1, -1, -1}, true, 9, palette[0], true},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			c, ok := brailleCell(tt.values, tt.pressed)
			if ok != tt.exists {
				t.Fatalf("exists = %v, want %v", ok, tt.exists)
			}
			if !ok {
				return
			}
			if c.Char != string(rune(0x2800+tt.mask)) || c.Color != tt.color || c.Background != "transparent" {
				t.Fatalf("unexpected cell: %+v", c)
			}
		})
	}
}

func TestImpactTiming(t *testing.T) {
	all := poses()
	contact, total := 0, 0
	for i, p := range all {
		total += p.duration
		if i < 16 {
			contact += p.duration
			if p.pressed || p.squash != 1 {
				t.Fatalf("pose %d is squashed before contact", i)
			}
			if i > 0 && p.scale <= all[i-1].scale {
				t.Fatalf("approach did not grow at pose %d", i)
			}
		} else if !p.pressed {
			t.Fatalf("pose %d lost the pressed expression", i)
		}
	}
	if contact != 810 || total != 1900 {
		t.Fatalf("contact=%d, total=%d", contact, total)
	}
}

func TestSampleTransparency(t *testing.T) {
	art := artwork{pressed: make([]byte, 192*192*3), normal: make([]byte, 192*192*4)}
	copy(art.pressed[:3], []byte{2, 53, 106})
	if art.sample(0, 0, true) != -1 || art.sample(0, 0, false) != -1 {
		t.Fatal("transparent pixels became visible")
	}
	copy(art.normal[:4], []byte{250, 250, 252, 255})
	if art.sample(0, 0, false) != 0 {
		t.Fatal("white sample did not match the palette")
	}
	for _, u := range []float64{-.01, 1, 1.01} {
		if art.sample(u, 0, false) != -1 {
			t.Fatal("outside pixel became visible")
		}
	}
}

func TestStaticLogoUsesFinalPose(t *testing.T) {
	p := project{Animation: animation{Frames: []frame{
		{Data: map[string]cell{"0,0": {Char: "⠁", Color: palette[0]}}},
		{Duration: 240, Data: map[string]cell{"0,0": {Char: "⣿", Color: palette[4]}}},
	}}}
	out, err := projectOutputs(p)
	if err != nil {
		t.Fatal(err)
	}
	if !strings.HasPrefix(string(out["fastfetch-gopher.txt"]), "$5⣿\n") {
		t.Fatal("static logo did not use the final pose")
	}
}

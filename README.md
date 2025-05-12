## 📂 dotfiles 
[![FOSSA Status](https://app.fossa.com/api/projects/custom%2B51440%2Fgit%40github.com%3Aanton-fuji%2Fdotfiles.git.svg?type=small)](https://app.fossa.com/projects/custom%2B51440%2Fgit%40github.com%3Aanton-fuji%2Fdotfiles.git?ref=badge_small)

## WezTerm Setup
To apply this configuration, place the files in the following directory
```bash:bash
~/.config/wezterm
```

### Features
- Customized colors and themes
- Background image setup
    - To set a custom background image, place your image file inside the `~/.config/wezterm/` directory.
    - Then, reference the image path in your `background.lua` file as follows ↓
    ```
    local background_image = "/Users/<your-username>/.config/wezterm/<image-file>"
    ```
- `Powerlevel10k` or `starship` integration (if applicable)
- Other tweaks and enhancements

### My WezTerm Overview
![Onerview](img/nvim-wez.png) 

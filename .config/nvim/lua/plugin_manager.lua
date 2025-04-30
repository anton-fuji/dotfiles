-- Set the path for the plugin
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- If the plugin does not exist at the specified path, clone it using Git
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end

-- Add the plugin path to the beginning of the runtime path
vim.opt.rtp:prepend(lazypath)

require('plugins')

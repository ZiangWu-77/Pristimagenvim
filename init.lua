-- File: ~/.config/nvim/init.lua
-- ======================================================================
-- common options
-- ======================================================================
-- Set termguicolors to true. This should be one of the first things you do.
vim.opt.termguicolors = true

require('config.lazy')

require('config.colorscheme')

require('config.options')

require('config.keymaps')

require('config.autocmds')

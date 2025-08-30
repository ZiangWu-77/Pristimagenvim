-- define your colorscheme here
-- local colorscheme = "tokyonight-night"
local colorscheme = "catppuccin"
vim.o.termguicolors = true
-- local colorscheme = "hardhacker"
local is_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not is_ok then
	vim.notify("colorscheme " .. colorscheme .. " not found!")
	return
end

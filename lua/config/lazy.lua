local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim, pointing it to the 'plugins' directory
require("lazy").setup("plugins", {
	-- You can add lazy.nvim options here, e.g., for performance tuning
	-- performance = {
	--     rtp = {
	--         disabled_plugins = {
	--             "gzip",
	--             "matchit",
	--             "matchparen",
	--             "netrwPlugin",
	--             "tarPlugin",
	--             "tohtml",
	--             "tutor",
	--             "zipPlugin",
	--         },
	--     },
	-- },
})

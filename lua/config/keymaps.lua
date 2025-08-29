-- define common options
local opts = {
	noremap = true, -- non-recursive
	silent = true, -- do not show message
}

-----------------
-- Normal mode --
-----------------

-- Hint: see `:h vim.map.set()`
-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
-- delta: 2 lines
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", opts)
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts)
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-----------------
-- Visual mode --
-----------------

-- Hint: start visual mode with the same area as the previous area and the same mode
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

vim.keymap.set({ "n", "i", "v", "c" }, "<C-s>", function()
	-- Use a pcall to safely execute the command.
	-- This will catch potential errors, e.g., trying to save a read-only file.
	local success, err = pcall(vim.cmd, "update")

	if success then
		-- On successful save, show an informational notification.
		local timestamp = os.date("%Y-%m-%d %H:%M:%S")
		vim.notify(
			"File has been saved at: " .. timestamp,
			vim.log.levels.INFO, -- Set the notification level to INFO
			{ title = "Saved" } -- Add a title to the notification window
		)
	else
		-- If saving fails, show an error notification.
		vim.notify(
			"Failed to save file: " .. tostring(err),
			vim.log.levels.ERROR, -- Set the notification level to ERROR
			{ title = "Error" } -- Add an error title
		)
	end
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { noremap = true, silent = true, desc = "Save current file" })

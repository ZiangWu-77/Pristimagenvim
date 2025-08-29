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

-- in lua/core/keymaps.lua

local keymap = vim.keymap

-- A safe way to close the buffer using bufferline
-- 使用 bufferline 来安全关闭缓冲区的函数
local function safe_close_buffer()
	-- pcall stands for "protected call".
	-- It will try to run the code, but won't throw an error if it fails.
	-- pcall 是“受保护的调用”，它会尝试运行代码，但如果失败了也不会抛出错误。
	local success, bufferline = pcall(require, "bufferline")

	if success then
		-- If the 'bufferline' module was loaded successfully, close the buffer.
		-- 如果 'bufferline' 模块被成功加载，就关闭缓冲区。
		bufferline.close_buffer()
	else
		-- If it failed (plugin not loaded yet), fall back to the native command.
		-- 如果失败了（插件还没加载），就回退到使用原生命令。
		vim.cmd("bd")
	end
end

-- Now, map the key to this safe function.
-- 现在，把快捷键映射到这个安全的函数上。
keymap.set("n", "<leader>c", safe_close_buffer, { desc = "Close current buffer (safe)" })

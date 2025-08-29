-- lua/config/autocmds.lua

local autocmd = vim.api.nvim_create_autocmd

-- Create an augroup to hold our autocmds.
-- This is a best practice as it allows us to clear the group on reload.
local trim_whitespace_group = vim.api.nvim_create_augroup("TrimWhitespace", { clear = true })

-- Define the autocmd
autocmd("BufWritePre", {
	group = trim_whitespace_group,
	pattern = "*", -- Run on all file types
	callback = function()
		-- Save the current cursor position
		local save_cursor = vim.fn.getpos(".")

		-- The command to delete trailing whitespace.
		-- :%s -> substitute on all lines in the buffer
		-- /\s\+$ -> match one or more whitespace characters (\s\+) at the end of a line ($)
		-- // -> replace with nothing
		-- e -> do not show an error if no match is found
		vim.cmd("silent! %s/\\s\\+$//e")

		-- Restore the cursor position
		vim.fn.setpos(".", save_cursor)
	end,
})

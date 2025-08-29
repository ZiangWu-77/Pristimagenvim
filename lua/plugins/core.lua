-- lua/plugins/core.lua
return {
	-- Formatter (now with its config)
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},
	-- {
	-- 	"ckipp01/stylua-nvim",
	-- 	config = function()
	-- 		-- Keymap for manual formatting
	-- 		vim.keymap.set("n", "f", function()
	-- 			require("stylua-nvim").format_file()
	-- 		end, { noremap = true, silent = true, desc = "Format Lua file with StyLua" })
	--
	-- 		-- Autocmd for formatting on save
	-- 		local stylua_group = vim.api.nvim_create_augroup("StyluaFormatting", { clear = true })
	-- 		vim.api.nvim_create_autocmd("BufWritePre", {
	-- 			pattern = "*.lua",
	-- 			group = stylua_group,
	-- 			callback = function()
	-- 				require("stylua-nvim").format_file()
	-- 			end,
	-- 		})
	-- 	end,
	-- },
	{
		-- Install conform.nvim
		"stevearc/conform.nvim",
		-- This is not a required dependency, but it's often useful to install formatters automatically
		dependencies = { "mason.nvim" },
		opts = {
			-- Map of filetypes to the formatters to use
			-- The first formatter in the list will be the default
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform will run multiple formatters sequentially
				python = { "isort", "black" },
				-- Use a sub-list to run only the first available formatter
				javascript = { { "prettierd", "prettier" } },
				typescript = { { "prettierd", "prettier" } },
				html = { { "prettierd", "prettier" } },
				css = { { "prettierd", "prettier" } },
				json = { { "prettierd", "prettier" } },
				yaml = { { "prettierd", "prettier" } },
				markdown = { { "prettierd", "prettier" } },

				-- IMPORTANT: Do not add an entry for 'oil' filetype here
				-- This ensures no formatter will be attached to oil buffers
			},

			-- Configure saving files to trigger formatting
			format_on_save = {
				-- This is the recommended synchronous way of formatting on save
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
		},
		config = function(_, opts)
			require("conform").setup(opts)
		end,
	},
	-- LSP and tooling
	-- Mason: Neovim 里的 "Homebrew", "apt", "dnf", 用来安装后台工具
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	-- Mason-Lspconfig: Mason 和 Lspconfig 之间的桥梁
	{
		"williamboman/mason-lspconfig.nvim",
		-- 确保在 lspconfig 之前加载
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		config = function()
			-- 这个函数会自动把 Mason 安装的 LSP 连接到 lspconfig
			require("mason-lspconfig").setup({
				-- 在这里列出你希望 Mason 自动安装的 LSP 服务器
				ensure_installed = { "pyright", "ruff" },
			})
		end,
	},
	-- Nvim-Lspconfig: Neovim 官方的 LSP 配置工具
	{
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- 当 LSP 启动时要执行的函数 (比如设置快捷键)
			local on_attach = function(client, bufnr)
				-- 在这里设置只在 LSP 文件中生效的快捷键
				-- 例如: gd 跳转到定义, K 显示文档, gr 查找引用
				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
				end
				map("n", "gd", vim.lsp.buf.definition, "LSP: Go to Definition")
				map("n", "K", vim.lsp.buf.hover, "LSP: Hover Documentation")
				map("n", "gr", vim.lsp.buf.references, "LSP: Go to References")
				map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP: Code Action")

				vim.api.nvim_create_autocmd("CursorHold", {
					buffer = bufnr, -- 只在当前 LSP 附加的缓冲区生效
					callback = function()
						vim.diagnostic.open_float(nil, {
							scope = "cursor", -- 只显示光标下的诊断
							focusable = false, -- 窗口默认不可聚焦
							source = "always", -- 总是显示来源 (e.g., "pyright")
						})
					end,
				})
			end

			-- 为 Pyright (Python 类型检查和补全) 设置
			lspconfig.pyright.setup({
				on_attach = on_attach,
				capabilities = capabilities,
			})
			-- 为 Ruff (Python 代码检查和格式化) 设置
			lspconfig.ruff.setup({
				on_attach = on_attach,
				capabilities = capabilities,
			})
		end,
	},

	-- ===================================================================
	-- II. 补全引擎：nvim-cmp
	-- ===================================================================
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter", -- 插入模式时再加载
		dependencies = {
			"hrsh7th/cmp-nvim-lsp", -- LSP 补全源
			"hrsh7th/cmp-buffer", -- Buffer 文本补全源
			"hrsh7th/cmp-path", -- 文件路径补全源
			"L3MON4D3/LuaSnip", -- Snippet 引擎
			"saadparwaiz1/cmp_luasnip", -- Snippet 补全源
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				-- 补全菜单的快捷键
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(), -- 主动触发补全
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- 回车选中
					["<Tab>"] = cmp.mapping.confirm({ select = true }),
					-- ["<Tab>"] = cmp.mapping(function(fallback)
					-- 	if cmp.visible() then
					-- 		cmp.select_next_item()
					-- 	elseif luasnip.expand_or_jumpable() then
					-- 		luasnip.expand_or_jump()
					-- 	else
					-- 		fallback()
					-- 	end
					-- end, { "i", "s" }),
					-- ["<S-Tab>"] = cmp.mapping(function(fallback)
					-- 	if cmp.visible() then
					-- 		cmp.select_prev_item()
					-- 	elseif luasnip.jumpable(-1) then
					-- 		luasnip.jump(-1)
					-- 	else
					-- 		fallback()
					-- 	end
					-- end, { "i", "s" }),
				}),
				-- 加载补全源
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
			})
		end,
	},
	--
	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
		opts = {
			ensure_installed = {
				"c",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"javascript",
				"typescript",
				"python",
				"rust",
				"go",
				"html",
				"css",
			},
			sync_install = false,
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
					},
				},
			},
		},
	},
	{
		"stevearc/oil.nvim",
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {
			-- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
			-- Set to false if you want some other plugin (e.g. netrw) to open when you edit directories.
			default_file_explorer = true,
			-- Id is automatically added at the beginning, and name at the end
			-- See :help oil-columns
			columns = {
				"icon",
				-- "permissions",
				-- "size",
				-- "mtime",
			},
			-- Buffer-local options to use for oil buffers
			buf_options = {
				buflisted = false,
				bufhidden = "hide",
			},
			-- Window-local options to use for oil buffers
			win_options = {
				wrap = false,
				signcolumn = "no",
				cursorcolumn = false,
				foldcolumn = "0",
				spell = false,
				list = false,
				conceallevel = 3,
				concealcursor = "nvic",
			},
			-- Send deleted files to the trash instead of permanently deleting them (:help oil-trash)
			delete_to_trash = true,
			-- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
			skip_confirm_for_simple_edits = false,
			-- Selecting a new/moved/renamed file or directory will prompt you to save changes first
			-- (:help prompt_save_on_select_new_entry)
			prompt_save_on_select_new_entry = true,
			-- Oil will automatically delete hidden buffers after this delay
			-- You can set the delay to false to disable cleanup entirely
			-- Note that the cleanup process only starts when none of the oil buffers are currently displayed
			cleanup_delay_ms = 2000,
			lsp_file_methods = {
				-- Enable or disable LSP file operations
				enabled = true,
				-- Time to wait for LSP file operations to complete before skipping
				timeout_ms = 1000,
				-- Set to true to autosave buffers that are updated with LSP willRenameFiles
				-- Set to "unmodified" to only save unmodified buffers
				autosave_changes = false,
			},
			-- Constrain the cursor to the editable parts of the oil buffer
			-- Set to `false` to disable, or "name" to keep it on the file names
			constrain_cursor = "editable",
			-- Set to true to watch the filesystem for changes and reload oil
			watch_for_changes = false,
			-- Keymaps in oil buffer.
			-- See :help oil-actions for a list of all available actions
			keymaps = {
				["g?"] = { "actions.show_help", mode = "n" },
				["<CR>"] = "actions.select",
				["<C-s>"] = { "actions.select", opts = { vertical = true } },
				["<C-h>"] = { "actions.select", opts = { horizontal = true } },
				["<C-t>"] = { "actions.select", opts = { tab = true } },
				["<C-p>"] = "actions.preview",
				["<C-c>"] = { "actions.close", mode = "n" },
				["<C-l>"] = "actions.refresh",
				["-"] = { "actions.parent", mode = "n" },
				["_"] = { "actions.open_cwd", mode = "n" },
				["`"] = { "actions.cd", mode = "n" },
				["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
				["gs"] = { "actions.change_sort", mode = "n" },
				["gx"] = "actions.open_external",
				["g."] = { "actions.toggle_hidden", mode = "n" },
				["g\\"] = { "actions.toggle_trash", mode = "n" },
				["ge"] = {
					desc = "Toggle file detailed view",
					callback = function()
						detail = not detail
						if detail then
							require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
						else
							require("oil").set_columns({ "icon" })
						end
					end,
				},
			},
			-- Set to false to disable all of the above keymaps
			use_default_keymaps = true,
			view_options = {
				-- Show files and directories that start with "."
				show_hidden = false,
				-- This function defines what is considered a "hidden" file
				is_hidden_file = function(name, bufnr)
					local m = name:match("^%.")
					return m ~= nil
				end,
				-- This function defines what will never be shown, even when `show_hidden` is set
				is_always_hidden = function(name, bufnr)
					return false
				end,
				-- Sort file names with numbers in a more intuitive order for humans.
				-- Can be "fast", true, or false. "fast" will turn it off for large directories.
				natural_order = "fast",
				-- Sort file and directory names case insensitive
				case_insensitive = false,
				sort = {
					-- sort order can be "asc" or "desc"
					-- see :help oil-columns to see which columns are sortable
					{ "type", "asc" },
					{ "name", "asc" },
				},
			},
			-- Configuration for the floating window in oil.open_float
			float = {
				-- Padding around the floating window
				padding = 2,
				max_width = 0,
				max_height = 0,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
				-- This is the config that will be passed to nvim_open_win.
				-- Change values here to customize the layout
				override = function(conf)
					return conf
				end,
			},
			-- Add other configurations from your snippet here...
		},
		-- Optional dependencies
		dependencies = { { "nvim-telescope/telescope.nvim" }, { "echasnovski/mini.icons", opts = {} } },
		-- Lazy loading is not recommended for oil.nvim
		lazy = false,
		keys = {
			-- 这是你的开关快捷键
			{
				"<leader>e", -- 你想绑定的按键 (可以换成别的，比如 "<leader>e")
				function()
					-- 这里的逻辑和 :OilToggle 命令里的完全一样
					local oil = require("oil")
					if vim.bo.filetype == "oil" then
						oil.close()
					else
						oil.open()
					end
				end,
				desc = "Toggle Oil (File Explorer)", -- which-key 的描述
			},
			{
				"<leader>di", -- "d" for debug, "i" for inspect
				function()
					-- Get the entry under the cursor
					local entry = require("oil").get_cursor_entry()
					-- Print it in a human-readable format
					print(vim.inspect(entry))
				end,
				desc = "[D]ebug: [I]nspect oil entry",
			},
			{
				"gy",
				function()
					-- 1. 获取当前 oil 窗口正在浏览的目录路径
					local dir = require("oil").get_current_dir()

					-- 2. 获取光标下条目的信息 (主要需要它的名字)
					local entry = require("oil").get_cursor_entry()

					-- 3. 确保我们成功获取了目录和条目信息
					if dir and entry and entry.name then
						-- 4. 使用 vim 的标准函数来安全地拼接路径 (这是最稳妥的做法)
						local path = vim.fs.joinpath(dir, entry.name)

						-- 5. 将拼接好的完整路径复制到系统剪贴板
						vim.fn.setreg("+", path)
						print("已复制路径: " .. path)
					else
						print("无法获取路径信息")
					end
				end,
				desc = "Copy absolute path",
			},
			{
				"<leader>fo", -- You can change this to any keybinding you like
				function()
					local default_path

					-- 1. Check if the current buffer is an oil buffer
					if vim.bo.filetype == "oil" then
						-- If it is, get the buffer name (e.g., "oil:///path/to/dir")
						local oil_buf_name = vim.api.nvim_buf_get_name(0)
						-- Remove the "oil://" prefix to get the real file system path
						-- The gsub function here replaces "oil://" at the start of the string with an empty string
						default_path = vim.fn.fnamemodify(oil_buf_name:gsub("^oil://", ""), ":h")
					else
						local current_buf_name = vim.api.nvim_buf_get_name(0)
						-- 2. If it's a regular buffer, check if it has a file name
						if current_buf_name ~= "" then
							-- If it has a name, use its directory as the default
							default_path = vim.fn.expand("%:p:h")
						else
							-- 3. If it's a new/unnamed buffer, use the current working directory
							default_path = vim.fn.getcwd()
						end
					end

					local path_input = vim.fn.input({
						prompt = "Open directory in Oil: ",
						-- Ensure the default path always ends with a separator for a better user experience
						default = default_path .. "/",
						completion = "dir",
					})

					if path_input == "" then
						print("Oil open cancelled.")
						return
					end

					require("oil").open(vim.fn.expand(path_input))
				end,
				desc = "Open a directory in Oil with prompt",
			},
			-- {
			-- 	"<leader>fo", -- 你可以把它改成任何你喜欢的快捷键
			-- 	function()
			-- 		-- 1. 调用内置输入函数，向用户索要路径
			-- 		local path_input = vim.fn.input({
			-- 			prompt = "Open directory in Oil: ",
			-- 			-- 默认值：当前文件所在的目录。如果当前是新 buffer，则为当前工作目录
			-- 			default = vim.fn.expand("%:p:h") .. "/",
			-- 			-- 开启目录补全功能！你可以在输入时按 Tab
			-- 			completion = "dir",
			-- 		})
			--
			-- 		-- 2. 如果用户按 Esc 或直接回车（输入为空），则取消操作
			-- 		if path_input == "" then
			-- 			print("Oil open cancelled.")
			-- 			return
			-- 		end
			--
			-- 		-- 3. 使用 oil.open 打开用户输入的路径
			-- 		--    我们用 vim.fn.expand 来处理像 '~' 这样的特殊字符
			-- 		require("oil").open(vim.fn.expand(path_input))
			-- 	end,
			-- 	desc = "Open a directory in Oil with prompt",
			-- },
		},
		-- 添加这个 config 函数
		config = function(_, opts)
			-- 调用默认的 setup 函数
			require("oil").setup(opts)

			-- 在这里放入你的自定义命令
			vim.api.nvim_create_user_command("OilToggle", function()
				local current_buf = vim.api.nvim_get_current_buf()
				local current_filetype = vim.api.nvim_buf_get_option(current_buf, "filetype")

				if current_filetype == "oil" then
					-- We use a command to go to the previous buffer
					vim.cmd("b#")
				else
					-- Open oil if not already in an oil buffer
					vim.cmd("Oil")
				end
			end, { nargs = 0 })
		end,
	},
	{
		"windwp/nvim-autopairs",
		-- Load the plugin only when entering insert mode
		event = "InsertEnter",
		-- Optional dependency for better integration with nvim-cmp
		-- dependencies = { "hrsh7th/nvim-cmp" },
		config = function()
			-- require the plugin and call the setup function
			local autopairs = require("nvim-autopairs")
			autopairs.setup({
				-- You can leave this empty to use the defaults
				check_ts = true, -- Enable treesitter integration
				ts_config = {
					lua = { "string" }, -- Don't add pairs inside lua strings
					javascript = { "template_string" },
					java = false,
				},
			})

			-- If you want to integrate with nvim-cmp
			-- This is not for blink.cmp, but is a common pattern to know
			-- local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			-- local cmp = require("cmp") -- Assuming nvim-cmp is installed
			-- if cmp then
			-- 	cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
			-- end
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		-- Using a tag is a good practice for version pinning
		tag = "0.1.8",
		-- Declare dependencies, lazy.nvim will handle them
		dependencies = { "nvim-lua/plenary.nvim" },

		-- The 'config' function runs after the plugin is loaded
		config = function()
			-- require the plugin's modules here
			local builtin = require("telescope.builtin")

			-- Set keymaps inside the config function
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[F]ind [B]uffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp tags" })
		end,
	},
	{
		"s1n7ax/nvim-window-picker",
		name = "window-picker",
		event = "VeryLazy",
		version = "2.*",
		config = function()
			require("window-picker").setup()
		end,
	},
}

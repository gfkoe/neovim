return {
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v3.x",
		lazy = true,
		config = false,
		init = function()
			-- Disable automatic setup, we are doing it manually
			vim.g.lsp_zero_extend_cmp = 0
			vim.g.lsp_zero_extend_lspconfig = 0
		end,
	},
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = true,
	},

	-- Autocompletion
	{
		"saghen/blink.cmp",
		-- optional: provides snippets for the snippet source
		dependencies = "rafamadriz/friendly-snippets",
		version = "*",
		opts = {
			keymap = { preset = "default" },
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},
			signature = { enabled = true },
		},
	},
	--{
	--	"hrsh7th/nvim-cmp",
	--	event = "InsertEnter",
	--	dependencies = {
	--		{ "L3MON4D3/LuaSnip" },
	--	},
	--	config = function()
	--		-- Here is where you configure the autocompletion settings.
	--		local lsp_zero = require("lsp-zero")
	--		lsp_zero.extend_cmp()

	--		-- And you can configure cmp even more, if you want to.
	--		local cmp = require("cmp")
	--		local cmp_action = lsp_zero.cmp_action()

	--		cmp.setup({
	--			sources = {
	--				{ name = "nvim_lsp", group_index = 2 },
	--				{ name = "copilot", group_index = 2 },
	--			},
	--			formatting = lsp_zero.cmp_format({ details = true }),
	--			mapping = cmp.mapping.preset.insert({
	--				["<C-Space>"] = cmp.mapping.complete(),
	--				["<C-u>"] = cmp.mapping.scroll_docs(-4),
	--				["<C-d>"] = cmp.mapping.scroll_docs(4),
	--				["<C-f>"] = cmp_action.luasnip_jump_forward(),
	--				["<C-b>"] = cmp_action.luasnip_jump_backward(),
	--			}),
	--		})
	--	end,
	--},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		cmd = { "LspInfo", "LspInstall", "LspStart" },
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			--{ "hrsh7th/cmp-nvim-lsp" },
			{ "saghen/blink.cmp" },
			{ "williamboman/mason-lspconfig.nvim" },
		},

		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			-- This is where all the LSP shenanigans will live
			local lsp_zero = require("lsp-zero")
			lsp_zero.extend_lspconfig()
			lsp_zero.setup({
				capabilities = capabilities,
			})

			--- if you want to know more about lsp-zero and mason.nvim
			--- read this: https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/integrate-with-mason-nvim.md
			lsp_zero.on_attach(function(client, bufnr)
				-- see :help lsp-zero-keybindings
				-- to learn the available actions
				lsp_zero.default_keymaps({ buffer = bufnr })
			end)

			require("mason-lspconfig").setup({
				capabilities = capabilities,
				ensure_installed = {
					"lua_ls",
				},
				handlers = {
					lsp_zero.default_setup,
					lua_ls = function()
						-- (Optional) Configure lua language server for neovim
						local lua_opts = lsp_zero.nvim_lua_ls()
						require("lspconfig").lua_ls.setup(lua_opts)
					end,
					denols = function()
						require("lspconfig").denols.setup({
							root_dir = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc"),
						})
					end,
					ts_ls = function()
						require("lspconfig").ts_ls.setup({
							root_dir = require("lspconfig.util").root_pattern("package.json"),
							single_file_support = false,
						})
					end,
				},
			})
		end,
	},
}

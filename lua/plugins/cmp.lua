return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/nvim-cmp",
		"hrsh7th/cmp-nvim-lsp-signature-help",
		"hrsh7th/cmp-nvim-lua",
		"rafamadriz/friendly-snippets",
		"onsails/lspkind.nvim",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"zbirenbaum/copilot-cmp",
	},

	config = function()
		require("copilot_cmp").setup()
		local cmp = require("cmp")
		local lspkind = require("lspkind")
		lspkind.init({
			symbol_map = {
				Copilot = "",
			},
		})

		vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#5abffa" })

		cmp.setup({
			preselect = cmp.PreselectMode.None,
			formatting = {
				format = lspkind.cmp_format({
					maxwidth = 15,
					ellipsis_char = "...",
					mode = "symbol",
				}),
			},
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
				end,
			},

			sorting = {
				priority_weight = 2,
				comparators = {
					require("copilot_cmp.comparators").prioritize,
					cmp.config.compare.offset,
					cmp.config.compare.exact,
					cmp.config.compare.score,
					cmp.config.compare.recently_used,
					cmp.config.compare.locality,
					cmp.config.compare.kind,
					cmp.config.compare.sort_text,
					cmp.config.compare.length,
					cmp.config.compare.order,
				},
			},
			mapping = {
				["<C-e>"] = cmp.mapping.abort(),
				["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
				["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
				["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i" }),
				["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i" }),
				["<CR>"] = cmp.mapping.confirm({ select = false}),
				["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
			},
			sources = cmp.config.sources({
				{ name = "copilot", group_index = 2 },
				{ name = "render-markdown", group_index = 2 },
				{ name = "luasnip", group_index = 2 },
				{ name = "nvim_lsp", group_index = 2 },
				{ name = "nvim_lsp_signature_help", group_index = 2 },
				{ name = "path", group_index = 2 },
				{ name = "nvim_lua", group_index = 2 },
				{ name = "lazydev", group_index = 0 },
			}, {
				{ name = "buffer" },
			}),
		})

		-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
		cmp.setup.cmdline({ "/", "?" }, {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})

		-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline" },
			}),
			matching = { disallow_symbol_nonprefix_matching = false },
		})

	end,
}



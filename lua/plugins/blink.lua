return {
  'saghen/blink.cmp',
  dependencies = {
		'rafamadriz/friendly-snippets',
		'folke/lazydev.nvim',
		'L3MON4D3/LuaSnip',
		{'saghen/blink.compat', lazy = true, version = false}
	},

  version = '1.*',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
			preset = 'default',
			['<C-d>'] = { 'show', 'show_documentation', 'hide_documentation' },
			['<C-e>'] = { 'hide', 'fallback' },
			['<CR>'] = { 'accept', 'fallback' },

			['<Up>'] = { 'select_prev', 'fallback' },
			['<Down>'] = { 'select_next', 'fallback' },
			['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
			['<C-n>'] = { 'select_next', 'fallback_to_mappings' },

			['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
			['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

			['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
		},
    appearance = {
      nerd_font_variant = 'mono'
    },
    completion = {
			ghost_text = {
				enabled = true
			},
			list = {
				selection = {
					preselect = false,
					auto_insert = false,
				}
			},
			keyword = {
				range = 'prefix',
			},
			trigger = {
				show_on_keyword = true,
			},
			documentation = { auto_show = false }
		},
		snippets = {
			preset = 'luasnip'
		},
    sources = {
      default = {'snippets', 'lazydev', 'lsp', 'path', 'buffer', 'obsidian', 'obsidian_new', 'obsidian_tags' },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
				obsidian = { name = "obsidian", module = "blink.compat.source" },
				obsidian_new = { name = "obsidian_new", module = "blink.compat.source" },
				obsidian_tags = { name = "obsidian_tags", module = "blink.compat.source" },


			}
		},

    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" }
}

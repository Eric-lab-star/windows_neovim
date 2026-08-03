return {
  'saghen/blink.cmp',
  dependencies = {
		'rafamadriz/friendly-snippets',
		'folke/lazydev.nvim',
		'L3MON4D3/LuaSnip',
	},

  version = '1.*',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
			preset = 'none',
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

			-- Snippet jumps live here rather than in LuaSnip's own keymaps,
			-- which used to collide with <C-k> above.
			['<C-l>'] = { 'snippet_forward', 'fallback' },
			['<C-h>'] = { 'snippet_backward', 'fallback' },
		},
    appearance = {
      nerd_font_variant = 'mono'
    },

    completion = {
			menu = {
				draw = {
					treesitter = {'lsp'},
				},
			},
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
			documentation = { auto_show = true }
		},
		snippets = {
			preset = 'luasnip'
		},

    sources = {
      -- obsidian.nvim now serves completions over an in-process LSP, so it
      -- arrives via the 'lsp' source; the old blink.compat shims are gone.
      default = {'snippets', 'lazydev', 'lsp', 'path', 'buffer' },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			}
		},

    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" }
}

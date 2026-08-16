return {
  'saghen/blink.cmp',
  -- lazydev 는 여기서 뺐다. dependencies 에 있으면 blink 가 eager 라서 같이
  -- 끌려오는데, 아래 providers.lazydev 가 module 로 지연 참조하고 lazydev 자신도
  -- ft = "lua" 를 갖고 있어서 필요한 순간에 알아서 로드된다.
  --
  -- LuaSnip 은 남긴다. snippets.preset = 'luasnip' 이 filetype 을 가리지 않고
  -- 쓰이므로 여기서 빼봐야 어차피 첫 완성에서 바로 로드된다.
  dependencies = {
		'rafamadriz/friendly-snippets',
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

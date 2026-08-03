return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	branch = 'main',
	build = ':TSUpdate',
	config = function()
		local treesitter = require('nvim-treesitter')
		treesitter.install {
			'powershell',
			'markdown',
			'markdown_inline',
			'rust',
			'javascript', 'cpp', 'cmake', 'json', 'java', 'lua',
			-- These back filetypes the config already targets (ts_ls, tailwind,
			-- pyright, lazydev) but had no parser, so treesitter.start() was a
			-- no-op there: no highlighting, no context-commentstring.
			'typescript', 'tsx', 'html', 'css', 'python',
			'vim', 'vimdoc', 'query', 'yaml', 'toml', 'bash', 'diff', 'gitcommit',
		}
	end,
}





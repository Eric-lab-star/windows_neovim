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
			'javascript', 'c', 'cpp', 'cmake', 'json', 'java', 'lua', 'go', 'xml',
			-- These back filetypes the config already targets (ts_ls, tailwind,
			-- pyright, lazydev) but had no parser, so treesitter.start() was a
			-- no-op there: no highlighting, no context-commentstring.
			'typescript', 'tsx', 'html', 'css', 'python',
			-- arduino_language_server attaches to .ino but the buffer had no
			-- parser, so it was the one filetype left without highlighting.
			'arduino',
			'vim', 'vimdoc', 'query', 'yaml', 'toml', 'bash', 'diff', 'gitcommit',
		}
	end,
}

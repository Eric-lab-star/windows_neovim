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
			'javascript', 'cpp', 'cmake', 'json', 'java', 'lua'
		}
	end,
}





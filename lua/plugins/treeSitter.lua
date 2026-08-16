return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	branch = 'main',
	build = ':TSUpdate',
	config = function()
		require("nvim-treesitter").install({
				"tsx",
				"typescript",
				"xml",
				"yaml",
				"c",
				"cpp",
				"lua",
				"vim",
				"vimdoc",
				"go",
				"markdown",
				"javascript",
				"rust",
				"python",
		})
	end,
}

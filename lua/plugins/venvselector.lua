return {
	"linux-cultist/venv-selector.nvim",
	-- The 'regexp' branch was merged into main (2025-08); 'v1' is frozen.
	branch = "main",

	dependencies = {
		"neovim/nvim-lspconfig",
		-- Listed without `branch`: telescope.lua already pins master, and the
		-- upstream README's `branch = "0.1.x"` would collide with it in lazy.
		"nvim-telescope/telescope.nvim",
		"nvim-lua/plenary.nvim",
	},

	ft = "python",

	keys = {
		{ "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Select python venv" },
	},

	opts = {
		search = {},
		options = {},
	},
}

return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {
		modes = {
			char = {
				jump_labels = true,
			},
		},
		highlight = {
			-- show a backdrop with hl FlashBackdrop
			backdrop = true,
			-- Highlight the search matches
			matches = true,
			-- extmark priority
			priority = 5000,
		}
	},

	keys = {
		{
			"s",
			mode = { "n","x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash",
		},
	},
}

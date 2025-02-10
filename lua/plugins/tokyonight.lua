return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,

		config = function()
			require("tokyonight").setup({
				style = "night",
				on_colors = function(colors)
					colors.bg_visual = "#42069c"
				end,
				on_highlights = function(hl, _)
					hl.IblScope = {
						fg = "#91064e",
						nocombine = true
					}

					hl.Cursor = {
						bg = "#fcba03",
						fg = "#1a1b26"
					}

					hl.lCursor = {
						bg = "#1a1b26",
						fg = "#1a1b26"
					}
				end,
				transparent = true

			})
			vim.cmd([[colorscheme tokyonight-night]])
		end,
	},
}

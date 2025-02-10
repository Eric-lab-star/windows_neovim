return {
	'nvim-lualine/lualine.nvim',
	opts = {
	},

	dependencies = {
		'nvim-tree/nvim-web-devicons',
		'linrongbin16/lsp-progress.nvim',
	},
	config = function ()
		require('lsp-progress').setup()
		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = "auto",
				component_separators = { left = '󰇙', right = '󰇙' },
				section_separators = { left = '', right = '' },
				disabled_filetypes = {},
				always_divide_middle = true
			},
			sections = {
				lualine_a = { 'mode' },
				lualine_b = { 'branch',
					{
						'diagnostics',
						sources = { "nvim_diagnostic" },
						symbols = {
							error = ' ',
							warn = ' ',
							info = ' ',
							hint = ' ',
						}
					}
				},
				lualine_c = {
					{
						'filename',
						path = 1,
					},
					{
						function()
							return require('lsp-progress').progress()
						end,
					}
				},

				lualine_x = {},
				lualine_y = {},
				lualine_z = {'location'},
			},

			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { 'filename' },
				lualine_x = { 'location' },
				lualine_y = {},
				lualine_z = {}
			},
			tabline = {},
			extensions = {}
		})
	end

}

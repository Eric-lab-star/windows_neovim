return {
	'nvim-lualine/lualine.nvim',
	-- statusline 은 첫 화면이 그려진 뒤에 붙어도 눈에 띄지 않는다. 이 한 줄로
	-- lsp-progress.nvim 까지 같이 뒤로 밀린다.
	event = "VeryLazy",
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

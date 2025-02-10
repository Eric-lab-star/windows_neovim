return {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
			'nvim-treesitter/nvim-treesitter',
			'nvim-tree/nvim-web-devicons',
		},
    opts = {
			callout = {
				time = {
					raw = '[!TIME]',
					rendered = '󰔟   ',
					highlight = 'RenderMarkdownWarn',
				}
			},
			sign = {
				enabled = false,
			}
		},
}

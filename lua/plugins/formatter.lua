return {
	"mhartington/formatter.nvim",
	opts = {},
	config = function()
		require("formatter").setup {
		logging = true,
		filetype = {
			lua = {
				require("formatter.filetypes.lua").stylua,
			},
			markdown = {
				require("formatter.defaults").prettier,
			},
			json = {
				require("formatter.defaults").prettier,
			},
			javascript = {
				require("formatter.defaults").prettier,
			},
			javascriptreact = {
				require("formatter.filetypes.javascriptreact").prettier,
			},
			typescript = {
				require("formatter.filetypes.typescript").prettier,
			},
			typescriptreact = {
				require("formatter.filetypes.typescriptreact").prettier,
			},
			rust = {
				require("formatter.filetypes.rust").rustfmt,
			},
			java = {
				require("formatter.filetypes.java").google_java_format
			}
		}
	}
	end
}

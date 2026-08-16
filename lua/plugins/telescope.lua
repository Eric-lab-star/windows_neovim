return {
	"nvim-telescope/telescope.nvim",
	branch = "master",

	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-project.nvim",
	},

	config = function()
		local builtin = require("telescope.builtin")
		local telescope = require("telescope")
		local actions = require("telescope.actions")


		telescope.setup({
			pickers = {
				buffers = {
					mappings = {
						i = {
							["<c-d>"] = actions.delete_buffer + actions.move_to_top,
						},
					},
				},
			},
			extensions = {
				project = {
					-- ~ 로 시작하는 상대 경로라 맥/윈도우 양쪽에서 홈 기준으로 풀린다.
					base_dirs = {
						'~/Programming/',
					},
				},
			}
		})

		require("telescope").load_extension("project")

		local keys = vim.keymap
		keys.set("n", "<leader>ff", builtin.find_files, {})
		keys.set("n", "<leader>fb", builtin.buffers, {})
		keys.set("n", "<leader>fg", builtin.live_grep, {})
		keys.set("n", "<leader>fs", builtin.current_buffer_fuzzy_find, {}) -- search in current buffer
		keys.set("n", "<leader>ma", builtin.marks, {}) -- list marks
		keys.set("n", "<leader>rr", builtin.registers, {}) -- list registers 
		keys.set("n", "<leader>oc", builtin.lsp_outgoing_calls, { noremap = true })
		keys.set("n", "<leader>ic", builtin.lsp_incoming_calls, { noremap = true })
		keys.set("n", "<leader>wd", builtin.diagnostics, { noremap = true })
		keys.set("n", "<leader>lg", builtin.live_grep, { noremap = true })
		keys.set("n", "<leader>pp", "<cmd>Telescope project<cr>")
	end,
}

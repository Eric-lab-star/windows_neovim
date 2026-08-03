return {
	"nvim-telescope/telescope.nvim",
	branch = "master",

	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-project.nvim",
		{"nvim-treesitter/nvim-treesitter", branch = "main"}
	},

	config = function()
		local builtin = require("telescope.builtin")
		local telescope = require("telescope")
		local actions = require("telescope.actions")


		telescope.setup({
			defaults = {},
			pickers = {
				buffers = {
					mappings = {
						i = {
							["<c-d>"] = actions.delete_buffer + actions.move_to_top,
						},
					},
				},
				-- find_command is a find_files option; under `defaults` it was
				-- silently ignored and telescope fell back to its own finder.
				find_files = {
					find_command = { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git" },
				},
				oldfiles = {},
				live_grep = {},
			},
			extensions = {
				project = {
					base_dirs = {
					},
				},
			}
		})

		require("telescope").load_extension("project")

			local keys = vim.keymap
		keys.set('n', '<leader>.', function() builtin.find_files({ cwd = vim.fn.expand('%:p:h') }) end)
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

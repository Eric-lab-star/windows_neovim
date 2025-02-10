return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		require("toggleterm").setup{
			direction = 'float',
			float_opts = {
				border = 'double',
			},
			start_in_insert = false,
			on_open = function(term)
				vim.api.nvim_buf_set_keymap(
					term.bufnr,
					"n",
					"q",
					"<cmd>close<CR>",
					{ noremap = true, silent = true }
				)
			end
		}

		vim.keymap.set("n", "<C-/>", "<cmd>ToggleTerm<cr>")

		vim.keymap.set(
			"n",
			"<leader>go",
			"<cmd>TermExec cmd='go run main.go' name='go run' direction=float<cr>"
		)
		vim.keymap.set(
			"n",
			"<leader>rs",
			"<cmd>TermExec cmd='cargo run' name='cargo run' direction=float<cr>"
		)

		local Terminal = require("toggleterm.terminal").Terminal
		local lazygit = Terminal:new({
			cmd = "lazygit",
			dir = "git_dir",
			direction = "float",
			float_opts = {
				border = "double",
			},
			-- function to run on opening the terminal
			on_open = function(term)
				vim.cmd("startinsert!")
				vim.keymap.set(
					"n",
					"q",
					"<cmd>close<CR>",
					{
						noremap = true,
						silent = true,
						buffer = term.bufnr
					}
				)
			end,
			-- function to run on closing the terminal
			on_close = function(term)
				vim.cmd("startinsert!")
			end,
		})

		local function _lazygit_toggle()
			lazygit:toggle()
		end

		vim.keymap.set(
			"n",
			"<leader>gg",
			_lazygit_toggle,
			{
				noremap = true,
				silent = true,
			}
		)

	end,
}

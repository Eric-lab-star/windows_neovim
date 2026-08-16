return {
	"nvim-telescope/telescope.nvim",
	branch = "master",

	-- 예전에는 트리거가 없어서 시작할 때 통째로 로드됐고, dependencies 를 통해
	-- plenary / telescope-project / nvim-treesitter 까지 같이 끌려왔다.
	cmd = "Telescope",

	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-project.nvim",
		{ "nvim-treesitter/nvim-treesitter", branch = "main" },
	},

	-- 키맵은 config 가 아니라 여기 있어야 한다. config 안에 두면 그걸 등록하려고
	-- 플러그인을 먼저 로드해야 해서 lazy 로딩이 성립하지 않는다.
	--
	-- 각 함수 안에서 require 하는 것도 같은 이유다. 스펙 최상단에서
	-- require("telescope.builtin") 을 해버리면 스펙을 읽는 시점 = 시작 시점에
	-- telescope 가 로드된다.
	keys = {
		{
			"<leader>.",
			function()
				require("telescope.builtin").find_files({ cwd = vim.fn.expand("%:p:h") })
			end,
			desc = "Find files (current file's dir)",
		},
		{ "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
		{ "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Buffers" },
		{ "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Live grep" },
		{ "<leader>lg", function() require("telescope.builtin").live_grep() end, desc = "Live grep" },
		{
			"<leader>fs",
			function() require("telescope.builtin").current_buffer_fuzzy_find() end,
			desc = "Search in current buffer",
		},
		{ "<leader>ma", function() require("telescope.builtin").marks() end, desc = "Marks" },
		{ "<leader>rr", function() require("telescope.builtin").registers() end, desc = "Registers" },
		{ "<leader>oc", function() require("telescope.builtin").lsp_outgoing_calls() end, desc = "LSP outgoing calls" },
		{ "<leader>ic", function() require("telescope.builtin").lsp_incoming_calls() end, desc = "LSP incoming calls" },
		{ "<leader>wd", function() require("telescope.builtin").diagnostics() end, desc = "Diagnostics" },
		{ "<leader>pp", "<cmd>Telescope project<cr>", desc = "Projects" },
	},

	config = function()
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

		telescope.load_extension("project")
	end,
}

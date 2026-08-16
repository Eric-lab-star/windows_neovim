return {
	"akinsho/toggleterm.nvim",
	version = "*",
	opts = {},
	config = function()
		require("toggleterm").setup({
			size = function(term)
				if term.direction == "horizontal" then
					return 15
				elseif term.direction == "vertical" then
					return vim.o.columns * 0.4
				end
			end,
			terminal_mappings = true,
			hide_numbers = false,
		})

		local Terminal = require("toggleterm.terminal").Terminal

		local miniTerm = Terminal:new({
			direction = "float",
		})

		-- 떠 있는 터미널 하나를 토글한다. C/C++ 빌드·실행은 <Space>(cppbuild.lua) 가 맡는다.
		vim.keymap.set({ "n", "t" }, "<C-s>", function()
			miniTerm:toggle()
		end, {})
	end,
}

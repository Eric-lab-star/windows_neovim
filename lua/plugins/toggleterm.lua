return {
	'akinsho/toggleterm.nvim',
	version = "*",
	opts = {},
	config = function ()
		require("toggleterm").setup({
			size = function(term)
				if term.direction == "horizontal" then
					return 15
				elseif term.direction == "vertical" then
					return vim.o.columns * 0.4
				end
			end,
			terminal_mappings= true,
			hide_numbers = false,
			shell = "pwsh -NoLogo",
		})


		local Terminal = require("toggleterm.terminal").Terminal

		local path = vim.fn.expand('%:p:h') -- Get the full path of the current file
		local dirname = vim.fn.fnamemodify(path, ':t')

		local miniTerm = Terminal:new({
			cmd = "pwsh -NoLogo",
			hidden= true,
		})

		local compiler = function ()
			if vim.bo.filetype == "arduino" then
				if miniTerm:is_open() == true then
					miniTerm:send("arduino-cli compile ".. "." , true)
				else
					miniTerm:toggle()
					miniTerm:send("arduino-cli compile ".. "." , true)
				end
			else
				print(dirname)
			end
		end

		local upload = function ()
			if vim.bo.filetype == "arduino" then
				if miniTerm:is_open() == true then
					miniTerm:send("arduino-cli upload ".. "." , true)
				else
					miniTerm:toggle()
					miniTerm:send("arduino-cli upload ".. "." , true)
				end
			else
				print(dirname)
			end
		end

		local serialPort = function ()
			if vim.bo.filetype == "arduino" then
				if miniTerm:is_open() == true then
					miniTerm:send("arduino-cli monitor -p COM3 -c baudrate=9600".. "." , true)
				else
					miniTerm:toggle()
					miniTerm:send("arduino-cli monitor -p COM3 -c baudrate=9600".. "." , true)
				end
			else
				print(dirname)
			end
		end
		vim.keymap.set(
			{"n"},
			"<C-s>",
			function ()
				miniTerm:toggle()
			end,{}
		)


		vim.keymap.set(
			"n",
			"<F4>",
			serialPort,
			{noremap = true}
		)

		vim.keymap.set(
			"n",
			"<F3>",
			upload,
			{noremap = true}
		)

		vim.keymap.set(
			"n",
			"<F2>",
			compiler,
			{noremap = true}
		)
	end
}

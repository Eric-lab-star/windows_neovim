return {
	'akinsho/toggleterm.nvim',
	version = "*",

	-- 실제 매핑은 아래 config 에서 만든다. 여기 있는 건 lazy.nvim 이 대신 걸어두는
	-- 스텁이라, 누르면 플러그인을 로드한 뒤 진짜 매핑으로 키를 다시 흘려보낸다.
	-- 그래서 lhs 만 적으면 되고 config 쪽은 건드릴 필요가 없다.
	keys = {
		{ "<C-s>", mode = { "n", "t" }, desc = "Toggle terminal" },
		{ "<F2>", desc = "Compile (arduino/cpp)" },
		{ "<F3>", desc = "Upload (arduino)" },
		{ "<F4>", desc = "Serial monitor (arduino)" },
	},
	cmd = { "ToggleTerm", "TermExec" },

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

		-- mapped to F2
		-- compile aruduino
		local compiler = function ()
			if vim.bo.filetype == "arduino" then
				if miniTerm:is_open() == true then
					miniTerm:send("arduino-cli compile ".. "." , true)
				else
					miniTerm:toggle()
					miniTerm:send("arduino-cli compile ".. "." , true)
				end
			elseif vim.bo.filetype == "cpp" then
				if miniTerm:is_open() == false then
					miniTerm:toggle()
				else
					miniTerm:send("ninja -C build" , true)
				end
			end
		end

		-- mapped to F3 
		-- upload to arduino
		local runner = function ()
			if vim.bo.filetype == "arduino" then
				if miniTerm:is_open() == true then
					miniTerm:send("arduino-cli upload ".. "." , true)
				else
					miniTerm:toggle()
					miniTerm:send("arduino-cli upload ".. "." , true)
				end
			elseif vim.bo.filetype == "cpp" then
				print("not implemented yet")
			end
		end

		local serialPort = function ()
			if vim.bo.filetype == "arduino" then
				if miniTerm:is_open() == true then
					miniTerm:send("arduino-cli monitor -c baudrate=9600".. "." , true)
				else
					miniTerm:toggle()
					miniTerm:send("arduino-cli monitor -c baudrate=9600".. "." , true)
				end
			else
				print(dirname)
			end
		end

		vim.keymap.set(
			{"n", "t"},
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
			runner,
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

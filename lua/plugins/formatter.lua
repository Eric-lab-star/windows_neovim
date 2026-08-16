return {
	"mhartington/formatter.nvim",
	opts = {},
	config = function()
		-- macOS에서 clang-format은 CommandLineTools 안에만 있고 PATH에는 없는 경우가 많다.
		-- brew install clang-format 을 하면 PATH 쪽이 우선 잡힌다.
		local function clangformat()
			-- CommandLineTools 경로는 맥 전용이라, 다른 OS 에서는 PATH 에 맡긴다.
			local fallback = vim.fn.has("mac") == 1
					and "/Library/Developer/CommandLineTools/usr/bin/clang-format"
				or "clang-format"
			local exe = vim.fn.executable("clang-format") == 1 and "clang-format" or fallback
			return {
				exe = exe,
				-- .clang-format 탐색과 언어 판별에 실제 파일명이 필요하다(stdin이라 넘겨줘야 함).
				args = { "--assume-filename", vim.api.nvim_buf_get_name(0) },
				stdin = true,
			}
		end

		require("formatter").setup({
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
					require("formatter.filetypes.java").google_java_format,
				},
				python = {
					require("formatter.filetypes.python").ruff,
				},
				c = {
					clangformat,
				},
				cpp = {
					clangformat,
				},
				["*"] = {
					-- "formatter.filetypes.any" defines default configurations for any
					-- filetype
					require("formatter.filetypes.any").remove_trailing_whitespace,
					-- Remove trailing whitespace without 'sed'
					-- require("formatter.filetypes.any").substitute_trailing_whitespace,
				},
			},
		})
		-- formatter.nvim 설정 이후에 추가
		-- 주의: 저장 시 포맷 autocmd 는 반드시 이 한 곳에만 존재해야 한다.
		local augroup = vim.api.nvim_create_augroup("FormatAutogroup", { clear = true })

		vim.api.nvim_create_autocmd("BufWritePost", {
			group = augroup,
			callback = function(args)
				-- 실제 파일 버퍼에만 적용 (terminal, oil://, quickfix 등 특수 버퍼 제외)
				if vim.bo[args.buf].buftype ~= "" or not vim.bo[args.buf].modifiable then
					return
				end
				vim.cmd("FormatWrite")
			end,
		})
	end,
}

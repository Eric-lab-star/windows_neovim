-- formatter.nvim 에서 이전(2026-08). 바꾼 이유는 하나다: 저장 한 번에 파일이 두
-- 번 쓰였다.
--
-- formatter.nvim 은 비동기라 BufWritePre 에서 쓸 수가 없어서 BufWritePost 에
-- 걸어야 했다. 그러면 순서가 `:w`(포맷 전 내용이 디스크로) -> 포맷 -> 플러그인이
-- 내부에서 다시 `update`(format.lua:256, noautocmd 아님) 가 된다. 포맷 자체는
-- format.lua:9 의 재진입 가드 덕에 한 번만 돌지만, 쓰기는 두 번이고 그 중 첫
-- 번째가 미포맷 내용이라 파일을 watch 하는 쪽(vite, tsc --watch 등)이 매 저장마다
-- 두 번, 그것도 한 번은 잘못된 내용으로 반응했다.
--
-- conform 은 BufWritePre 에서 동기로 돌아서 쓰기가 한 번이다.
return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },

	keys = {
		{
			"<leader>fm",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = { "n", "x" },
			desc = "Format buffer",
		},
	},

	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			markdown = { "prettier" },
			json = { "prettier" },
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			rust = { "rustfmt" },
			java = { "google-java-format" },
			cpp = { "clang_format" },
			-- 순서 중요: import 정렬 후 포맷.
			python = { "ruff_organize_imports", "ruff_format" },
		},

		formatters = {
			-- clang-format 은 PATH 에 없다. clangd 와 같은 LLVM 릴리즈 안에 풀려
			-- 있을 뿐이라 lsp.lua 의 CLANGD 와 같은 방식으로 전체 경로를 준다.
			clang_format = {
				command = "C:/Users/cyon2/clang+llvm-20.1.0-x86_64-pc-windows-msvc/bin/clang-format.exe",
			},
		},

		-- notify_on_error 는 기본값(true) 그대로 둔다. 여기 적힌 포매터는 전부 실제로
		-- 설치돼 있으므로, 에러가 뜬다면 그건 진짜 실패(파일 문법 오류, prettier
		-- 설정 문제 등)라서 묻으면 안 된다. 어떤 포매터가 잡혔는지는 :ConformInfo.

		format_on_save = function()
			if vim.g.format_on_save == false then
				return
			end
			return { timeout_ms = 3000, lsp_format = "fallback" }
		end,
	},

	init = function()
		-- gq 를 conform 으로 넘긴다.
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,

	config = function(_, opts)
		require("conform").setup(opts)

		-- :FormatOnSaveToggle -- 잠시 끄고 싶을 때.
		-- vim.g.format_on_save 는 처음에 nil 이고, nil == false 가 false 라 첫 토글이
		-- 정확히 '끄기' 가 된다.
		vim.api.nvim_create_user_command("FormatOnSaveToggle", function()
			vim.g.format_on_save = (vim.g.format_on_save == false)
			vim.notify("format on save: " .. tostring(vim.g.format_on_save))
		end, { desc = "Toggle format on save" })
	end,
}

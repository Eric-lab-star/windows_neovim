local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		lazyrepo,
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- conceallevel = 2
vim.opt.cole = 2
vim.opt.cmdheight = 1

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

vim.diagnostic.config({
	virtual_text = false,
})

vim.o.winborder = "single"

vim.opt.shadafile = "NONE"
vim.opt.ignorecase = true

vim.opt.termguicolors = true
vim.opt.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25,r-cr-o:hor20"

vim.opt.incsearch = true

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.fileformat = "unix"
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.smarttab = true
vim.opt.clipboard = "unnamed"
vim.opt.encoding = "UTF-8"
vim.opt.inccommand = "split"
vim.opt.swapfile = false
vim.opt.autoindent = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

vim.opt.pumheight = 10
vim.opt.backupcopy = "yes"

vim.cmd("autocmd TermOpen * startinsert")

-- A helper for shorter mapping
local map = vim.keymap.set

vim.opt.langmap = {
	-- Movement
	"ㅗh",
	"ㅓj",
	"ㅏk",
	"ㅣl",

	-- Editing
	"ㅇd",
	"ㅛy",
	"ㅔp",
	"ㅐo",
	"ㅌx",
	"ㅕu",

	-- Visual mode
	"ㅂv",

	-- Search
	"ㅡ/",

	-- Uppercase variants
	"ㅇD",
	"ㅛY",
	"ㅔP",
	"ㅐO",
	"ㅌX",
	"ㅕU",
	"ㅂV",
	"ㅡ?",
}

-- Save
vim.cmd.cnoreabbrev("ㅈ w")
-- Quit
vim.cmd.cnoreabbrev("ㅂ q")
-- Save & Quit
vim.cmd.cnoreabbrev("ㅈㅂ wq")
-- Force Quit
vim.cmd.cnoreabbrev("ㅃ q!")
-- Write All
vim.cmd.cnoreabbrev("ㅈㅈ wa")

vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })

-- desc 는 which-key 목록에 그대로 뜬다. 새 매핑을 추가할 때도 꼭 적어 줄 것.
vim.keymap.set("n", "<C-h>", "<cmd>BufferPrevious<cr>", { desc = "이전 버퍼" })

vim.keymap.set("n", "<c-l>", "<cmd>BufferNext<cr>", { desc = "다음 버퍼" })

vim.keymap.set("n", "<leader>dd", "<cmd>BufferClose<cr>", { desc = "버퍼 닫기" })

vim.keymap.set("n", "<A-,>", "<cmd>BufferMovePrevious<cr>", { desc = "버퍼 왼쪽으로 이동" })

vim.keymap.set("n", "<A-.>", "<cmd>BufferMoveNext<cr>", { desc = "버퍼 오른쪽으로 이동" })

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Oil: 파일 탐색" })

vim.keymap.set("n", "<C-g>g", "<CMD>NvimTreeFindFile<CR>", { desc = "NvimTree: 현재 파일 찾기" })

--- lsp configs
vim.lsp.inlay_hint.enable()
local key = vim.keymap
local opt = { noremap = true }

local function lspkey(lhs, fn, desc)
	key.set("n", lhs, fn, { noremap = true, desc = desc })
end

-- Nvim 0.11+ 는 gra(code action) / gri(implementation) / grn(rename) /
-- grr(references) / grt(type definition) 을 기본 제공한다. gr 을 직접 매핑하면
-- 그 접두사를 가로채 gr* 전부가 timeoutlen 만큼 지연되므로 매핑하지 않는다.
-- 참조 목록은 기본 매핑 grr 을 쓸 것.
lspkey("<leader>rn", vim.lsp.buf.rename, "LSP: 이름 바꾸기")
lspkey("gd", vim.lsp.buf.definition, "LSP: 정의로 이동")
lspkey("gD", vim.lsp.buf.declaration, "LSP: 선언으로 이동")
lspkey("K", vim.lsp.buf.hover, "LSP: 문서 보기")
lspkey("<C-k>", vim.lsp.buf.signature_help, "LSP: 인자 힌트")
lspkey("<leader>ca", vim.lsp.buf.code_action, "LSP: 코드 액션")

vim.keymap.set("n", "<C-Up>", ":resize +2<cr>", { noremap = true, desc = "창 높이 +2" })

vim.keymap.set("n", "<C-Down>", ":resize -2<cr>", { noremap = true, desc = "창 높이 -2" })

vim.keymap.set("n", "<C-Left>", ":vertical resize -2<cr>", { noremap = true, desc = "창 너비 -2" })

vim.keymap.set("n", "<C-Right>", ":vertical resize +2<cr>", { noremap = true, desc = "창 너비 +2" })

-- tree-sitter
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		pcall(vim.treesitter.start)
	end,
})

-- NOTE: 저장 시 포맷은 lua/plugins/formatter.lua 의 FormatAutogroup 한 곳에서만 처리한다.
-- 여기에 BufWritePost -> FormatWrite 를 다시 등록하면 저장 1회당 포맷 파이프라인이
-- 2개 동시에 돌면서 서로의 결과를 덮어쓰고 파일이 두 번 기록된다.

-- Python 파일에서 <Space> 누르면 ToggleTerm으로 uv run main.py 실행
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.keymap.set("n", "<Space>", function()
			-- 저장 후 실행
			vim.cmd("write")

			local Terminal = require("toggleterm.terminal").Terminal
			local runner = Terminal:new({
				cmd = "uv run main.py",
				direction = "float", -- float, vertical, horizontal, tab 중 선택
				close_on_exit = false, -- 실행 끝나도 터미널 유지 (결과 확인용)
				on_open = function(term)
					-- 터미널 열릴 때 insert mode 진입 방지 (결과만 볼 때 편함)
					vim.cmd("stopinsert")
				end,
			})
			runner:toggle()
		end, { buffer = true, desc = "Run Python with uv" })
	end,
})

-- clangd 헤더 <-> 소스 전환
vim.keymap.set("n", "<leader>ch", function()
	local client = vim.lsp.get_clients({ bufnr = 0, name = "clangd" })[1]
	if not client then
		vim.notify("clangd가 이 버퍼에 붙어있지 않습니다", vim.log.levels.WARN)
		return
	end
	client:request("textDocument/switchSourceHeader", { uri = vim.uri_from_bufnr(0) }, function(err, result)
		if err or not result then
			vim.notify("대응하는 헤더/소스 파일을 찾지 못했습니다", vim.log.levels.WARN)
			return
		end
		vim.cmd.edit(vim.uri_to_fname(result))
	end, 0)
end, { desc = "clangd: switch source/header" })

-- C/C++ 파일에서 <Space> 누르면 CMake로 빌드 후 실행 (python 쪽과 같은 패턴).
-- 실제 로직은 lua/config/cppbuild.lua 에 있다. 산출물은 <프로젝트>/build/bin 에 남는다.
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp" },
	callback = function()
		vim.keymap.set("n", "<Space>", function()
			require("config.cppbuild").build_and_run()
		end, { buffer = true, desc = "CMake build & run" })
	end,
})

-- add_executable 이 여러 개인 프로젝트에서 실행할 타깃을 바꾼다(한 번 고르면 기억한다).
vim.api.nvim_create_user_command("CppTarget", function()
	require("config.cppbuild").build_and_run({ pick = true })
end, { desc = "CMake 실행 타깃 다시 선택" })

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client == nil then
			return
		end
		if client.name == "ruff" then
			-- Disable hover in favor of Pyright
			client.server_capabilities.hoverProvider = false
		end
	end,
	desc = "LSP: Disable hover capability from Ruff",
})

-- Setup lazy.nvim
--
require("lazy").setup({
	spec = {
		-- import your plugins
		{ import = "plugins" },
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
	change_detection = {
		notify = false,
		enabled = true,
	},
})

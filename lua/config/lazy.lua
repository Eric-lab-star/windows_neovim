local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
	  "git",
	  "clone",
	  "--filter=blob:none",
	  "--branch=stable",
	  lazyrepo,
	  lazypath
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
vim.opt.cmdheight = 0

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

-- virtual_text 는 계속 끈다(줄 끝에 붙어서 잘리니까). 대신 0.11+ 의 virtual_lines
-- 로 커서가 놓인 줄에만 진단 전문을 아래에 펼친다. 예전에는 virtual_text=false
-- 하나뿐이라 Trouble 을 열기 전에는 메시지를 볼 방법이 아예 없었다.
vim.diagnostic.config({
	virtual_text = false,
	virtual_lines = { current_line = true },
})

vim.o.winborder='single'

vim.opt.ignorecase=true

vim.opt.termguicolors=true
vim.opt.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25,r-cr-o:hor20"

vim.opt.incsearch=true
vim.lsp.log.set_level(vim.log.levels.WARN)

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.fileformat="unix"
vim.opt.termguicolors = true
vim.opt.number=true
vim.opt.relativenumber=true
vim.opt.smarttab=true
vim.opt.clipboard="unnamed"
vim.opt.encoding="UTF-8"
vim.opt.inccommand="split"
vim.opt.swapfile = false
vim.opt.autoindent=true

vim.opt.tabstop=2
vim.opt.shiftwidth=2

vim.opt.pumheight = 10

vim.cmd("autocmd TermOpen * startinsert")



-- A helper for shorter mapping
local map = vim.keymap.set

vim.opt.langmap = {
  -- Movement
  "ㅗh", "ㅓj", "ㅏk", "ㅣl",

  -- Editing
  "ㅇd", "ㅛy", "ㅔp", "ㅐo", "ㅌx", "ㅕu",

  -- Visual mode
  "ㅂv",

  -- Search
  "ㅡ/",

  -- Uppercase variants
  "ㅇD", "ㅛY", "ㅔP", "ㅐO", "ㅌX", "ㅕU", "ㅂV", "ㅡ?"
}



-- Save
vim.cmd.cnoreabbrev('ㅈ w')
-- Quit
vim.cmd.cnoreabbrev('ㅂ q')
-- Save & Quit
vim.cmd.cnoreabbrev('ㅈㅂ wq')
-- Force Quit
vim.cmd.cnoreabbrev('ㅃ q!')
-- Write All
vim.cmd.cnoreabbrev('ㅈㅈ wa')

vim.keymap.set(
	't',
	'<Esc>',
	[[<C-\><C-n>]],
	{ noremap = true, silent = true }
)


vim.keymap.set(
	"n",
	"<C-h>",
	"<cmd>BufferPrevious<cr>"
)

vim.keymap.set(
	"n",
	"<c-l>",
	"<cmd>BufferNext<cr>"
)

vim.keymap.set(
	"n",
	"<leader>dd",
	"<cmd>BufferClose<cr>"
)

vim.keymap.set(
	"n",
	"<A-,>",
	"<cmd>BufferMovePrevious<cr>"
)

vim.keymap.set(
	"n",
	"<A-.>",
	"<cmd>BufferMoveNext<cr>"
)

vim.keymap.set(
	"n",
	"-",
	"<CMD>Oil<CR>"
)

vim.keymap.set(
	"n",
	"<C-g>g",
	"<CMD>NvimTreeFindFile<CR>"
)

--- lsp configs 
vim.lsp.inlay_hint.enable()
local key = vim.keymap
local opt = {noremap = true}

key.set("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opt)
key.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opt)
key.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opt)
key.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opt)
key.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opt)
key.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opt)
key.set("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opt)
key.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opt)

vim.keymap.set(
	"n",
	"<C-Up>",
	":resize +2<cr>",
	opt
)

vim.keymap.set(
	"n",
	"<C-Down>",
	":resize -2<cr>",
	opt
)

vim.keymap.set(
	"n",
	"<C-Left>",
	":vertical resize -2<cr>",
	opt
)

vim.keymap.set(
	"n",
	"<C-Right>",
	":vertical resize +2<cr>",
	opt
)


-- tree-sitter
--
-- main 브랜치는 master 와 달리 highlight 외에는 아무것도 자동으로 붙여주지
-- 않는다. vim.treesitter.start() 가 highlight 만 켜므로 indent 와 fold 는 여기서
-- 직접 건다.
--
-- 쿼리가 있는 언어에만 건다. indents/folds 쿼리가 없는 파서에 indentexpr 를
-- 걸어버리면 built-in indent(예: lua, python) 를 빼앗아놓고 아무것도 못 해서
-- 들여쓰기가 오히려 나빠진다.
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    if not pcall(vim.treesitter.start) then
      return
    end

    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
    if not lang then
      return
    end

    if vim.treesitter.query.get(lang, 'indents') then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end

    if vim.treesitter.query.get(lang, 'folds') then
      -- wo[0][0] = 현재 창이되 이 버퍼에서만. 그냥 wo 로 걸면 나중에 그 창에
      -- 다른 파일을 띄웠을 때 foldexpr 가 따라다닌다.
      vim.wo[0][0].foldmethod = 'expr'
      vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end
  end,
})

-- foldmethod=expr 는 기본 foldlevel 이 0 이라 파일을 열자마자 전부 접힌다.
-- 99 로 두면 접기는 쓸 수 있되(zc/za/zR) 열 때는 항상 펼쳐진 상태다.
vim.opt.foldlevelstart = 99

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
	}
})

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

vim.diagnostic.config({
	virtual_text = false,
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
vim.api.nvim_create_autocmd('FileType', {
  callback = function() pcall(vim.treesitter.start) end,
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
	}
})

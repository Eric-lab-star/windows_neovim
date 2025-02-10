-- Bootstrap lazy.nvim
-- 
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

vim.opt.cmdheight = 0
vim.api.nvim_create_autocmd(
	{"CmdlineLeave"},
	{
		pattern = {"*"},
		callback = function(ev) vim.opt.cmdheight = 0 end
	}
)
vim.api.nvim_create_autocmd(
	{"CmdlineEnter"},
	{
		pattern = {"*"},
		callback = function(ev) vim.opt.cmdheight = 1 end
	}
)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

vim.diagnostic.config({
	virtual_text = false,
})

vim.opt.ignorecase=true
vim.opt.termguicolors=true
vim.opt.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25,r-cr-o:hor20"

vim.opt.incsearch=true
vim.lsp.set_log_level("warn")

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true
vim.opt.number=true
vim.opt.relativenumber=true
vim.opt.smarttab=true
vim.opt.clipboard="unnamed"
vim.opt.encoding="UTF-8"
vim.opt.inccommand="split"
vim.opt.swapfile = false
vim.opt.autoindent=true
vim.opt.tabstop=4
vim.opt.shiftwidth=4
vim.opt.pumheight = 10
vim.keymap.set(
	't',
	'<Esc>',
	[[<C-\><C-n>]],
	{ noremap = true, silent = true }
)

vim.keymap.set(
	"n",
	"<C-h>",
	"<cmd>bp<cr>"
)

vim.keymap.set(
	"n",
	"<c-l>",
	"<cmd>bn<cr>"
)

vim.keymap.set(
	"n",
	"<leader>dd",
	"<cmd>bd<cr>"
)

vim.keymap.set(
	"n",
	"<m-1>",
	"<cmd>%bd|e#|bd#<cr>"
)

vim.keymap.set(
	"n",
	"-",
	"<CMD>Oil<CR>"
)


-- Setup lazy.nvim
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

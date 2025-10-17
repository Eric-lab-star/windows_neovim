return {
	'neovim/nvim-lspconfig',
	opt = {},
	init = function()
		vim.lsp.config['lua_ls'] = {
		on_init = function(client)
		 if client.workspace_folders then
			 local path = client.workspace_folders[1].name
			 if
				 path ~= vim.fn.stdpath('config')
				 and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
			 then
				 return
			 end
		 end
			client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
			 runtime = {
				 version = 'LuaJIT',
				 path = {
					 'lua/?.lua',
					 'lua/?/init.lua',
				 },
			 },
			 workspace = {
				 checkThirdParty = false,
				 library = {
					 vim.env.VIMRUNTIME
				 }
			 }
			})
		end,
		settings = {
		 Lua = {
			 runtime = {
				 version = "LuaJIT" },
			 diagnostics = {
				 globals = { 'vim' },
			 }
		 }
		}
  }

	vim.lsp.config('arduino_language_server', {
		cmd = {"arduino-language-server", "-cli-config" , "C:/Users/cyon2/AppData/Local/Arduino15/arduino-cli.yaml"},
		filetypes = {"arduino"},
		root_markers = {".yaml"},
		settings = {
			clangd = {"C:/Users/cyon2/clang+llvm-20.1.0-x86_64-pc-windows-msvc/bin/clangd.exe"},
			cli = {"C:/Users/cyon2/arduino_cli/bin"},
			fqbn = {
				"arduino:avr:uno"
			}
		},
	})

	vim.lsp.enable({
			'lua_ls',
			'ts_ls',
			'tailwindcss',
			'jdtls',
			'pyright',
			'arduino_language_server',
			'clangd',
			'cmake',
		})
	end,
}

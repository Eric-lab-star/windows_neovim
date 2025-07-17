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
				 version = "LuaJIT"
			 },
			 diagnostics = {
				 globals = { 'vim' },
			 }
		 }
		}
  }
	vim.lsp.enable({
			'lua_ls',
			'ts_ls',
			'tailwindcss',
			'jdtls',
		})
	end
}


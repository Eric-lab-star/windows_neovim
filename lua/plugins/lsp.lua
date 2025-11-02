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
	vim.lsp.config('tailwindcss', {
		settings = {
			tailwindCSS = {
				experimental = {
					classRegex = {
						{ "([\"'`][^\"'`]*.*?[\"'`])", "[\"'`]([^\"'`]*).*?[\"'`]" }
					}},
				classAttributes = { "class", "className", "class:list", "classList", "ngClass" },
				includeLanguages = {
					eelixir = "html-eex",
					elixir = "phoenix-heex",
					eruby = "erb",
					heex = "phoenix-heex",
					htmlangular = "html",
					templ = "html"
				},
				lint = {
					cssConflict = "warning",
					invalidApply = "error",
					invalidConfigPath = "error",
					invalidScreen = "error",
					invalidTailwindDirective = "error",
					invalidVariant = "error",
					recommendedVariantOrder = "warning"
				},
				validate = true
			}
		}
	})

	vim.lsp.enable({
		'tailwindCSS',
			'lua_ls',
			'ts_ls',
			'jdtls',
			'pyright',
			'arduino_language_server',
			'clangd',
			'cmake',
		})
	end,
}

return {
	'neovim/nvim-lspconfig',
	init = function()
		vim.lsp.config('lua_ls', {
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
		})

		vim.lsp.config('arduino_language_server', {
			cmd = {"arduino-language-server", "-cli-config" , "C:/Users/cyon2/AppData/Local/Arduino15/arduino-cli.yaml"},
			filetypes = {"arduino"},
			-- root_markers matches exact file names; ".yaml" is not a real one.
			root_markers = {"sketch.yaml", ".git"},
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

		-- Names must match nvim-lspconfig's lsp/<name>.lua exactly. 'tailwindCSS'
		-- silently resolved to a *separate* config on case-insensitive Windows,
		-- which threw away the settings above.
		--
		-- Only enable servers whose executable is actually present, otherwise
		-- Neovim errors on every matching buffer with "cmd ... is not executable".
		local servers = {
			lua_ls                  = 'lua-language-server',
			ts_ls                   = 'typescript-language-server',
			tailwindcss             = 'tailwindcss-language-server',
			jdtls                   = 'jdtls',
			pyright                 = 'pyright-langserver',
			clangd                  = 'clangd',
			cmake                   = 'cmake-language-server',
			arduino_language_server = 'arduino-language-server',
		}

		for server, exe in pairs(servers) do
			if vim.fn.executable(exe) == 1 then
				vim.lsp.enable(server)
			end
		end

		-- :LspWhich -- report which of the configured servers are missing.
		vim.api.nvim_create_user_command('LspWhich', function()
			local lines = {}
			for server, exe in pairs(servers) do
				local found = vim.fn.executable(exe) == 1
				table.insert(lines, ('%-24s %-32s %s'):format(server, exe, found and 'ok' or 'MISSING'))
			end
			table.sort(lines)
			vim.notify(table.concat(lines, '\n'))
		end, { desc = 'Show which configured LSP servers are installed' })
	end,
}

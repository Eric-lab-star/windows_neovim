return {
	'neovim/nvim-lspconfig',
	init = function()
		-- Windows: npm's global bin ships three files per package --
		-- `pyright-langserver` (a bash shim, no extension), `.cmd` and `.ps1`.
		-- vim.fn.executable() consults PATHEXT and matches, so the enable gate
		-- below passes, but libuv can only spawn the `.cmd`. The result was a
		-- server that silently never attached, reporting only "Spawning
		-- language server with cmd: `{ "pyright-langserver", "--stdio" }`
		-- failed" -- pyright was dead this way. Servers installed as real .exe
		-- shims (lua_ls via scoop) are unaffected and fall through unchanged.
		--
		-- This cannot read the default cmd out of vim.lsp.config: lazy.nvim
		-- runs init() before nvim-lspconfig is on the runtimepath, so
		-- lsp/<name>.lua has not been resolved yet and cmd is still nil. It
		-- resolves the executable itself instead.
		local function npm_cmd(exe)
			local resolved = vim.fn.exepath(exe)
			if
				vim.fn.has('win32') == 1
				and resolved ~= ''
				-- Only the basename matters; parent dirs may contain dots.
				and not vim.fs.basename(resolved):find('%.')
				and vim.uv.fs_stat(resolved .. '.cmd')
			then
				return resolved .. '.cmd'
			end
			return exe
		end

		-- clangd ships as a plain .exe inside an unpacked LLVM release rather
		-- than on PATH, so executable('clangd') is 0 and the gate below skips
		-- it. Same path the arduino server's settings already point at.
		local CLANGD = 'C:/Users/cyon2/clang+llvm-20.1.0-x86_64-pc-windows-msvc/bin/clangd.exe'

		-- Same situation for the arduino pair: both are loose .exe files in a
		-- hand-made directory rather than on PATH, so they are referenced in
		-- full. arduino-language-server has no scoop package and is not on npm
		-- -- it is the official 0.7.7 release binary, dropped next to the CLI.
		local ARDUINO_CLI = 'C:/Users/cyon2/arduino_cli/bin/arduino-cli.exe'
		local ARDUINO_LS = 'C:/Users/cyon2/arduino_cli/bin/arduino-language-server.exe'

		vim.lsp.config('clangd', { cmd = { CLANGD } })

		-- Both are npm installs, so both need the .cmd shim on Windows.
		vim.lsp.config('ts_ls', {
			cmd = { npm_cmd('typescript-language-server'), '--stdio' },
		})

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

		-- arduino-language-server takes clangd/cli/fqbn as COMMAND-LINE FLAGS,
		-- not as LSP `settings`. They used to sit in a settings table, where
		-- the server never saw them -- it would fall back to looking for
		-- `clangd` and `arduino-cli` on PATH, neither of which is there.
		-- `-cli` also wants the executable itself, not the directory.
		vim.lsp.config('arduino_language_server', {
			cmd = {
				ARDUINO_LS,
				'-cli-config', 'C:/Users/cyon2/AppData/Local/Arduino15/arduino-cli.yaml',
				'-cli', ARDUINO_CLI,
				'-clangd', CLANGD,
				'-fqbn', 'arduino:avr:uno',
			},
			filetypes = {"arduino"},
			-- root_markers matches exact file names; ".yaml" is not a real one.
			root_markers = {"sketch.yaml", ".git"},
		})

		vim.lsp.config('tailwindcss', {
			cmd = { npm_cmd('tailwindcss-language-server'), '--stdio' },
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

		-- Locate the interpreter pyright should resolve imports against. A
		-- project-local venv wins over an activated one, so opening project B
		-- from a shell with project A activated still analyses B's packages.
		local function venv_python(root)
			local dirs = {}
			if root then
				table.insert(dirs, root .. '/.venv')
				table.insert(dirs, root .. '/venv')
			end
			if vim.env.VIRTUAL_ENV then
				table.insert(dirs, vim.env.VIRTUAL_ENV)
			end

			local bin = vim.fn.has('win32') == 1 and '/Scripts/python.exe' or '/bin/python'
			for _, dir in ipairs(dirs) do
				local py = dir .. bin
				if vim.uv.fs_stat(py) then
					return py
				end
			end
		end

		vim.lsp.config('pyright', {
			-- Resolved to the .cmd shim on Windows; see npm_cmd above.
			cmd = { npm_cmd('pyright-langserver'), '--stdio' },
			-- vim.lsp.config merges with tbl_deep_extend('force'), which replaces
			-- arrays wholesale -- so lspconfig's defaults have to be repeated here.
			-- '.venv'/'venv' are added so a bare script next to a venv still gets a
			-- workspace root instead of falling back to single-file mode.
			root_markers = {
				'pyrightconfig.json',
				'pyproject.toml',
				'setup.py',
				'setup.cfg',
				'requirements.txt',
				'Pipfile',
				'.venv',
				'venv',
				'.git',
			},
			before_init = function(_, config)
				local py = venv_python(config.root_dir)
				if py then
					-- Mutate in place. Client.new() aliases this exact table as
					-- client.settings before before_init runs, so reassigning
					-- config.settings would break the alias and drop the setting.
					config.settings.python = config.settings.python or {}
					config.settings.python.pythonPath = py
				end
			end,
		})

		-- Names must match nvim-lspconfig's lsp/<name>.lua exactly. 'tailwindCSS'
		-- silently resolved to a *separate* config on case-insensitive Windows,
		-- which threw away the settings above.
		--
		-- Only enable servers whose executable is actually present, otherwise
		-- Neovim errors on every matching buffer with "cmd ... is not executable".
		--
		-- NOTE: this gate is weaker than it looks on Windows. vim.fn.executable()
		-- consults PATHEXT and happily matches npm's *extension-less* bash shim
		-- (e.g. scoop/.../bin/pyright-langserver, no .cmd), which libuv then
		-- cannot spawn -- so a server can pass this check and still fail with
		-- "Spawning language server ... failed". Real .exe shims (lua_ls via
		-- scoop) are unaffected. If an npm-installed server never attaches,
		-- that's the reason: point its cmd at the .cmd shim.
		--
		-- mdx_analyzer is deliberately ABSENT. It is installed
		-- (npm i -g @mdx-js/language-server, 0.6.3 = latest) and mdx.nvim gives
		-- it the 'mdx' filetype it needs, but the server crashes on startup:
		--   vscode-markdown-languageservice@0.5.0 does `import uri from
		--   'vscode-uri'` while vscode-uri 3.x exports only { URI, Utils } --
		--   no default. Verified 3.0.8 and 3.1.0 both lack it, so pinning
		--   inside its ^3.0.7 range does not help, and 0.6.3 is the newest
		--   published server. Upstream packaging bug (microsoft/vscode#192144).
		-- Adding it back only spams a spawn/crash error on every .mdx buffer.
		-- Re-add once a release fixes it; treesitter highlighting is unaffected.
		-- jdtls is deliberately ABSENT: nvim-jdtls starts and attaches it from
		-- ftplugin/java.lua (one server per project root, with its own -data
		-- workspace), so enabling it here too would start a second client.
		local servers = {
			lua_ls                  = 'lua-language-server',
			ts_ls                   = 'typescript-language-server',
			tailwindcss             = 'tailwindcss-language-server',
			pyright                 = 'pyright-langserver',
			clangd                  = CLANGD,
			cmake                   = 'cmake-language-server',
			arduino_language_server = ARDUINO_LS,
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

-- arduino-cli.yaml 위치는 OS 마다 다르다. 맥/윈도우 양쪽에서 이 설정이 그대로 돌아가도록
-- 경로를 하드코딩하지 않고 실행 시점에 푼다.
--   macOS   ~/Library/Arduino15/arduino-cli.yaml
--   Windows %LOCALAPPDATA%\Arduino15\arduino-cli.yaml
--   Linux   ~/.arduino15/arduino-cli.yaml
local function arduino_cli_config()
	if vim.fn.has("mac") == 1 then
		return vim.fn.expand("~/Library/Arduino15/arduino-cli.yaml")
	end
	if vim.fn.has("win32") == 1 then
		local appdata = vim.env.LOCALAPPDATA or vim.fn.expand("~/AppData/Local")
		return appdata .. "\\Arduino15\\arduino-cli.yaml"
	end
	return vim.fn.expand("~/.arduino15/arduino-cli.yaml")
end

-- clangd 는 어느 쪽에서도 PATH 에 없는 경우가 많다. 맥은 brew llvm 이 keg-only 라
-- 안 잡히고, 윈도우는 LLVM 릴리즈를 그냥 풀어놓은 디렉터리라 안 잡힌다.
-- PATH -> brew -> 윈도우 LLVM 순으로 찾는다.
local WIN_CLANGD = "C:/Users/cyon2/clang+llvm-20.1.0-x86_64-pc-windows-msvc/bin/clangd.exe"
local function clangd_path()
	if vim.fn.executable("clangd") == 1 then
		return "clangd"
	end
	local brew = "/usr/local/opt/llvm/bin/clangd"
	if vim.uv.fs_stat(brew) then
		return brew
	end
	if vim.uv.fs_stat(WIN_CLANGD) then
		return WIN_CLANGD
	end
	return "clangd"
end

-- arduino 쪽 두 실행 파일도 같은 사정이다. 윈도우에서는 손으로 만든 디렉터리에
-- 놓인 .exe 라 전체 경로로 가리킨다. arduino-language-server 는 scoop 패키지도
-- npm 패키지도 없는 공식 0.7.7 릴리즈 바이너리다.
local function arduino_exe(name, win_path)
	if vim.fn.executable(name) == 1 then
		return name
	end
	return win_path
end

return {
	"neovim/nvim-lspconfig",
	init = function()
		-- lsp.log는 자동 회전되지 않아 무한정 커진다. 디버깅할 때만 "warn"/"debug"로 올릴 것.
		vim.lsp.log.set_level("off")

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
				vim.fn.has("win32") == 1
				and resolved ~= ""
				-- Only the basename matters; parent dirs may contain dots.
				and not vim.fs.basename(resolved):find("%.")
				and vim.uv.fs_stat(resolved .. ".cmd")
			then
				return resolved .. ".cmd"
			end
			return exe
		end

		local CLANGD = clangd_path()
		local ARDUINO_CLI = arduino_exe("arduino-cli", "C:/Users/cyon2/arduino_cli/bin/arduino-cli.exe")
		local ARDUINO_LS =
			arduino_exe("arduino-language-server", "C:/Users/cyon2/arduino_cli/bin/arduino-language-server.exe")

		vim.lsp.config("clangd", {
			cmd = {
				CLANGD,
				"--background-index",
				"--clang-tidy",
				"--header-insertion=iwyu",
				"--completion-style=detailed",
				"--function-arg-placeholders",
				"--fallback-style=llvm",
			},
			init_options = {
				usePlaceholders = true,
				completeUnimported = true,
				clangdFileStatus = true,
			},
			-- 인코딩은 clangd 기본값(utf-8) 그대로 둔다. ruff/pyright와 달리 C/C++ 버퍼에는
			-- clangd 하나만 붙으므로 서로 열 위치가 어긋날 상대가 없다.
			-- 굳이 바꿔야 한다면 표준 general.positionEncodings가 아니라 clangd 확장인
			-- capabilities.offsetEncoding = { "utf-16" } 을 써야 lspconfig 기본값을 덮는다.
		})

		-- Both are npm installs, so both need the .cmd shim on Windows.
		vim.lsp.config("ts_ls", {
			cmd = { npm_cmd("typescript-language-server"), "--stdio" },
		})

		vim.lsp.config("lua_ls", {
			on_init = function(client)
				if client.workspace_folders then
					local path = client.workspace_folders[1].name
					if
						path ~= vim.fn.stdpath("config")
						and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
					then
						return
					end
				end
				client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
					runtime = {
						version = "LuaJIT",
						path = {
							"lua/?.lua",
							"lua/?/init.lua",
						},
					},
					workspace = {
						checkThirdParty = false,
						library = {
							vim.env.VIMRUNTIME,
						},
					},
				})
			end,
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					diagnostics = {
						globals = { "vim" },
					},
				},
			},
		})

		-- arduino-language-server takes clangd/cli/fqbn as COMMAND-LINE FLAGS,
		-- not as LSP `settings`. They used to sit in a settings table, where
		-- the server never saw them -- it would fall back to looking for
		-- `clangd` and `arduino-cli` on PATH, neither of which is there.
		-- `-cli` also wants the executable itself, not the directory.
		vim.lsp.config("arduino_language_server", {
			cmd = {
				ARDUINO_LS,
				"-cli-config",
				arduino_cli_config(),
				"-cli",
				ARDUINO_CLI,
				"-clangd",
				CLANGD,
				"-fqbn",
				"arduino:avr:uno",
			},
			filetypes = { "arduino" },
			-- root_markers matches exact file names; ".yaml" is not a real one.
			root_markers = { "sketch.yaml", ".git" },
		})

		vim.lsp.config("tailwindcss", {
			cmd = { npm_cmd("tailwindcss-language-server"), "--stdio" },
			settings = {
				tailwindCSS = {
					experimental = {
						classRegex = {
							{ "([\"'`][^\"'`]*.*?[\"'`])", "[\"'`]([^\"'`]*).*?[\"'`]" },
						},
					},
					classAttributes = { "class", "className", "class:list", "classList", "ngClass" },
					includeLanguages = {
						eelixir = "html-eex",
						elixir = "phoenix-heex",
						eruby = "erb",
						heex = "phoenix-heex",
						htmlangular = "html",
						templ = "html",
					},
					lint = {
						cssConflict = "warning",
						invalidApply = "error",
						invalidConfigPath = "error",
						invalidScreen = "error",
						invalidTailwindDirective = "error",
						invalidVariant = "error",
						recommendedVariantOrder = "warning",
					},
					validate = true,
				},
			},
		})

		-- ruff는 기본이 utf-8, pyright는 utf-16이라 같은 버퍼에서 열 위치가 어긋난다.
		-- 비ASCII 문자가 있는 줄에서 진단/코드액션 위치가 밀리는 것을 막기 위해 utf-16으로 통일.
		-- hover 는 pyright 쪽에 양보한다(lua/config/lazy.lua 의 LspAttach autocmd).
		vim.lsp.config("ruff", {
			capabilities = {
				general = {
					positionEncodings = { "utf-16" },
				},
			},
		})

		-- Locate the interpreter pyright should resolve imports against. A
		-- project-local venv wins over an activated one, so opening project B
		-- from a shell with project A activated still analyses B's packages.
		local function venv_python(root)
			local dirs = {}
			if root then
				table.insert(dirs, root .. "/.venv")
				table.insert(dirs, root .. "/venv")
			end
			if vim.env.VIRTUAL_ENV then
				table.insert(dirs, vim.env.VIRTUAL_ENV)
			end

			local bin = vim.fn.has("win32") == 1 and "/Scripts/python.exe" or "/bin/python"
			for _, dir in ipairs(dirs) do
				local py = dir .. bin
				if vim.uv.fs_stat(py) then
					return py
				end
			end
		end

		vim.lsp.config("pyright", {
			-- Resolved to the .cmd shim on Windows; see npm_cmd above.
			cmd = { npm_cmd("pyright-langserver"), "--stdio" },
			-- vim.lsp.config merges with tbl_deep_extend('force'), which replaces
			-- arrays wholesale -- so lspconfig's defaults have to be repeated here.
			-- '.venv'/'venv' are added so a bare script next to a venv still gets a
			-- workspace root instead of falling back to single-file mode.
			root_markers = {
				"pyrightconfig.json",
				"pyproject.toml",
				"setup.py",
				"setup.cfg",
				"requirements.txt",
				"Pipfile",
				".venv",
				"venv",
				".git",
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
		-- 맥/윈도우 공용으로 쓰려면 이 게이트가 필요하다: 한쪽에만 깔린 서버를
		-- 무조건 enable 하면 다른 쪽에서 매 버퍼마다 에러가 난다.
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
		--
		-- jdtls is deliberately ABSENT: nvim-jdtls starts and attaches it from
		-- ftplugin/java.lua (one server per project root, with its own -data
		-- workspace), so enabling it here too would start a second client.
		-- rust_analyzer 도 같은 이유로 없다: rustaceanvim 이 직접 띄운다.
		local servers = {
			lua_ls = "lua-language-server",
			ts_ls = "typescript-language-server",
			tailwindcss = "tailwindcss-language-server",
			pyright = "pyright-langserver",
			ruff = "ruff",
			clangd = CLANGD,
			cmake = "cmake-language-server",
			arduino_language_server = ARDUINO_LS,
		}

		for server, exe in pairs(servers) do
			if vim.fn.executable(exe) == 1 then
				vim.lsp.enable(server)
			end
		end

		-- :LspWhich -- report which of the configured servers are missing.
		vim.api.nvim_create_user_command("LspWhich", function()
			local lines = {}
			for server, exe in pairs(servers) do
				local found = vim.fn.executable(exe) == 1
				table.insert(lines, ("%-24s %-32s %s"):format(server, exe, found and "ok" or "MISSING"))
			end
			table.sort(lines)
			vim.notify(table.concat(lines, "\n"))
		end, { desc = "Show which configured LSP servers are installed" })
	end,
}

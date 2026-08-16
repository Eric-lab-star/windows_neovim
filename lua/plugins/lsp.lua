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

-- brew llvm은 keg-only라 PATH에 잡히지 않는다. 있으면 그쪽(최신)을, 없으면 Xcode CLT 쪽 clangd를 쓴다.
local function clangd_path()
	local brew = "/usr/local/opt/llvm/bin/clangd"
	if vim.uv.fs_stat(brew) then
		return brew
	end
	return "clangd"
end

return {
	"neovim/nvim-lspconfig",
	opt = {},
	init = function()
		-- lsp.log는 자동 회전되지 않아 무한정 커진다. 디버깅할 때만 "warn"/"debug"로 올릴 것.
		vim.lsp.log.set_level("off")

		vim.lsp.config["lua_ls"] = {
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
		}
		vim.lsp.config("arduino_language_server", {
			cmd = { "arduino-language-server", "-cli-config", arduino_cli_config() },
			filetypes = { "arduino" },
			root_markers = { ".yaml" },
		})

		-- ruff는 기본이 utf-8, pyrefly는 utf-16이라 같은 버퍼에서 열 위치가 어긋난다.
		-- 비ASCII 문자가 있는 줄에서 진단/코드액션 위치가 밀리는 것을 막기 위해 utf-16으로 통일.
		vim.lsp.config("ruff", {
			capabilities = {
				general = {
					positionEncodings = { "utf-16" },
				},
			},
		})

		vim.lsp.config("tailwindcss", {
			settings = {
				tailwindCSS = {
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
					experimental = {
						classRegex = {
							{ "([\"'`][^\"'`]*.*?[\"'`])", "[\"'`]([^\"'`]*).*?[\"'`]" },
						},
					},
				},
			},
		})

		vim.lsp.config("clangd", {
			cmd = {
				clangd_path(),
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
			-- 인코딩은 clangd 기본값(utf-8) 그대로 둔다. ruff/pyrefly와 달리 C/C++ 버퍼에는
			-- clangd 하나만 붙으므로 서로 열 위치가 어긋날 상대가 없다.
			-- 굳이 바꿔야 한다면 표준 general.positionEncodings가 아니라 clangd 확장인
			-- capabilities.offsetEncoding = { "utf-16" } 을 써야 lspconfig 기본값을 덮는다.
		})

		vim.lsp.enable({
			"pyrefly",
			"ruff",
			"lua_ls",
			"ts_ls",
			"tailwindcss",
			"jdtls",
			"arduino_language_server",
			"cmake",
			"clangd",
			"rust_analyzer",
			-- mdx_analyzer: @mdx-js/language-server 0.6.3이 vscode-uri ESM 빌드와
			-- 호환되지 않아 실행 즉시 종료된다(upstream 버그). 수정되면 다시 활성화할 것.
		})
	end,
}

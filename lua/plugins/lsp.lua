return {
	"neovim/nvim-lspconfig",
	opts = {
		inlay_hints = {
			enabled = true,
		}
	},
	config = function()
		local key = vim.keymap
		local opt = { noremap = true }
		key.set("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opt)
		key.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opt)
		key.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opt)
		key.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opt)
		key.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opt)
		key.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opt)
		key.set("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opt)
		key.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opt)

		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		local lspconfig = require("lspconfig")

		lspconfig.sourcekit.setup({
			capabilities = {
				workspace = {
					didChangeWatchedFiles = {
						dynamicRegistration = true,
					},
				},
			},
		})

		lspconfig.cmake.setup({})
		lspconfig.ccls.setup({
			init_options = {
				compilationDatabaseDirectory = "build",
				index = {
					threads = 0,
				},
				clang = {
					excludeArgs = { "-frounding-math" },
				},
			},
		})

		lspconfig.rust_analyzer.setup({
			capabilities = capabilities,
			settings = {
				["rust-analyzer"] = {
					diagnostics = {
						enable = false,
					},
				},
			},
		})

		lspconfig.sqlls.setup({
			capabilities = capabilities,
		})
		lspconfig.gopls.setup({
			capabilities = capabilities,
		})

		lspconfig.lua_ls.setup({
			on_init = function(client)
				if client.workspace_folders then
					local path = client.workspace_folders[1].name
					if vim.loop.fs_stat(path .. "/.luarc.json") or 
						vim.loop.fs_stat(path .. "/.luarc.jsonc") then
						return
					end
				end

				client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
					runtime = {
						-- Tell the language server which version of Lua you're using
						-- (most likely LuaJIT in the case of Neovim)
						version = "LuaJIT",
					},
					-- Make the server aware of Neovim runtime files
					workspace = {
						checkThirdParty = false,
						library = {
							vim.env.VIMRUNTIME,
							-- Depending on the usage, you might want to add additional paths here.
							-- "${3rd}/luv/library"
							-- "${3rd}/busted/library",
						},
						-- or pull in all of 'runtimepath'. NOTE: this is a lot slower
						-- library = vim.api.nvim_get_runtime_file("", true)
					},
				})
			end,
			settings = {
				Lua = {},
			},
		})
	end,
}

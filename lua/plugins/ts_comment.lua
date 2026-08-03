-- Comment.nvim was dropped (unmaintained since 2023); Neovim 0.10+ ships gc /
-- gcc natively. This plugin stays on purely to fix 'commentstring' inside
-- embedded languages -- JSX/TSX attributes, <script> and <style> in HTML, etc.
return {
	"JoosepAlviste/nvim-ts-context-commentstring",
	lazy = false,
	init = function()
		-- Skip the plugin's own Comment.nvim shim, which no longer applies.
		vim.g.skip_ts_context_commentstring_module = true
	end,
	opts = {
		enable_autocmd = false,
	},
	config = function(_, opts)
		require("ts_context_commentstring").setup(opts)

		-- Hook the native commenting API so `gc` asks treesitter for the
		-- correct commentstring at the cursor position.
		local get_option = vim.filetype.get_option
		vim.filetype.get_option = function(filetype, option)
			if option ~= "commentstring" then
				return get_option(filetype, option)
			end
			return require("ts_context_commentstring.internal").calculate_commentstring()
				or get_option(filetype, option)
		end
	end,
}

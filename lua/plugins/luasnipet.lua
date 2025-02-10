
return {
	"L3MON4D3/LuaSnip",
	-- follow latest release.
	version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
 	dependencies = { "rafamadriz/friendly-snippets" },
	build = "make install_jsregexp",
	config = function()
		local ls = require("luasnip")
		local s = ls.snippet
		local sn = ls.snippet_node
		local isn = ls.indent_snippet_node
		local t = ls.text_node
		local i = ls.insert_node
		local f = ls.function_node
		local c = ls.choice_node
		local d = ls.dynamic_node
		local r = ls.restore_node
		local events = require("luasnip.util.events")
		local ai = require("luasnip.nodes.absolute_indexer")
		local extras = require("luasnip.extras")
		local l = extras.lambda
		local rep = extras.rep
		local p = extras.partial
		local m = extras.match
		local n = extras.nonempty
		local dl = extras.dynamic_lambda
		local fmt = require("luasnip.extras.fmt").fmt
		local fmta = require("luasnip.extras.fmt").fmta
		local conds = require("luasnip.extras.expand_conditions")
		local postfix = require("luasnip.extras.postfix").postfix
		local types = require("luasnip.util.types")
		local parse = require("luasnip.util.parser").parse_snippet
		local ms = ls.multi_snippet
		local k = require("luasnip.nodes.key_indexer").new_key

		ls.setup({
			update_events = "TextChanged, TextChangedI"
		})

		ls.add_snippets("lua", {
			s(
				"keymap",
				fmt([[
				vim.keymap.set(
					{},
					"{}",
					{},
				)
				]],
				{i(1, "\"n\""), i(2, "keys"), i(3,"cmd")})
			),
		})

		local function getTime()
			return os.date("%H:%M:%S")
		end


		ls.add_snippets("markdown", {
			s(
				"qtime",
				fmt(
					[[
					> [!TIME] {}
					]],
					{f(getTime)}
				)
			),
			s(
				"info",
				t("> [!INFO]")
			),
			s(
				"star",
				t("⭐")
			)

		})

		require("luasnip.loaders.from_vscode").lazy_load()

		vim.keymap.set({ "i", "s" }, "<C-k>", function()
			if ls.expand_or_jumpable() then
				ls.expand_or_jump()
			end
		end, { silent = true })

		vim.keymap.set({ "i", "s" }, "<C-j>", function()
			ls.jump(-1)
		end, { silent = true })

		vim.keymap.set(
			{"n"},
			"<leader><leader>s",
			"<cmd>Lazy reload LuaSnip <cr>"
		)

	end
}

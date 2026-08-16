return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		-- claudecode.nvim의 터미널 provider로 사용
		terminal = {},

		-- 큰 파일 열 때 syntax/LSP 비활성화해서 멈춤 방지
		bigfile = { enabled = true },

		-- 나머지는 기존 플러그인과 겹치므로 끔:
		-- picker/explorer -> telescope, nvim-tree, oil
		-- statuscolumn/dashboard/indent 등은 필요하면 여기서 enabled = true
	},
}

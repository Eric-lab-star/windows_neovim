-- 키를 누르고 잠깐 멈추면 이어지는 단축키 목록이 뜬다.
-- 목록에 뜨는 설명은 각 매핑의 desc 에서 온다. desc 를 안 적으면 명령어 원문이 그대로
-- 보이므로, 새 매핑을 만들 때는 desc 를 같이 적어 줄 것.
return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "modern",
		-- 키를 누른 뒤 목록이 뜨기까지의 시간(ms). 0 으로 두면 타이핑 중에도 계속 떠서
		-- 거슬리고, 너무 길면 도움이 안 된다.
		delay = 400,
		spec = {
			-- 접두사 자체에 이름을 붙여 둔다. 개별 키 설명은 desc 가 담당한다.
			{ "<leader>d", group = "디버그 / 버퍼" },
			{ "<leader>c", group = "코드" },
			{ "<leader>r", group = "리팩터" },
			{ "<C-g>", group = "NvimTree" },
			{ "g", group = "이동 / LSP" },
			{ "z", group = "폴드 / 화면" },
		},
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "이 버퍼의 단축키 보기",
		},
		{
			"<leader>K",
			function()
				require("which-key").show({ global = true })
			end,
			desc = "전체 단축키 보기",
		},
	},
}

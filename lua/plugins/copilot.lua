return {
	"zbirenbaum/copilot.lua",
	opts = {
		panel = {enabled = false},
		suggestion = {
			enabled = false,
			auto_trigger = false,
			hide_during_completion = true,
			debounce = 75,
			keymap = {
				accept = "<Right>",
				accept_word = false,
				accept_line = false,
				next = "<C-l>",
				prev = "<c-h>",
				dismiss = "<Left>"
			},
		},
	},
	event = "InsertEnter",
}



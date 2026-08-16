-- C/C++/Rust 디버깅. 어댑터는 lldb-dap 를 쓴다.
-- brew install llvm 이 되어 있으면 그쪽(최신)을, 없으면 Xcode CommandLineTools 쪽을 쓴다.
local function lldb_dap_path()
	local brew = "/usr/local/opt/llvm/bin/lldb-dap"
	if vim.uv.fs_stat(brew) then
		return brew
	end
	if vim.fn.executable("lldb-dap") == 1 then
		return vim.fn.exepath("lldb-dap")
	end
	-- Xcode CommandLineTools 는 맥에만 있다. 다른 OS 에서는 이름만 넘겨 PATH 에 맡긴다.
	if vim.fn.has("mac") == 1 then
		return "/Library/Developer/CommandLineTools/usr/bin/lldb-dap"
	end
	return "lldb-dap"
end

return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
			},
			"theHamsta/nvim-dap-virtual-text",
		},
		keys = {
			-- step 계열이 F10/F11/F12 이므로 시작/계속도 F 키로 맞춘다.
			-- 예전에는 "55" 였는데, 노멀 모드에서 5가 count 접두사라 55j / 55G 같은
			-- 카운트를 잡아먹는 문제가 있어 바꿨다.
			{ "<F5>", function() require("dap").continue() end, desc = "DAP: 시작/계속" },
			{ "<F10>", function() require("dap").step_over() end, desc = "DAP: step over" },
			{ "<F11>", function() require("dap").step_into() end, desc = "DAP: step into" },
			{ "<F12>", function() require("dap").step_out() end, desc = "DAP: step out" },
			{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP: breakpoint 토글" },
			{
				"<leader>dB",
				function()
					vim.ui.input({ prompt = "조건식: " }, function(cond)
						if cond and cond ~= "" then
							require("dap").set_breakpoint(cond)
						end
					end)
				end,
				desc = "DAP: 조건부 breakpoint",
			},
			{ "<leader>dr", function() require("dap").repl.toggle() end, desc = "DAP: REPL 토글" },
			{ "<leader>dl", function() require("dap").run_last() end, desc = "DAP: 마지막 세션 재실행" },
			{ "<leader>dt", function() require("dap").terminate() end, desc = "DAP: 종료" },
			{ "<leader>du", function() require("dapui").toggle() end, desc = "DAP UI 토글" },
			{
				"<leader>de",
				function() require("dapui").eval(nil, { enter = true }) end,
				mode = { "n", "v" },
				desc = "DAP: 표현식 평가",
			},
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()
			require("nvim-dap-virtual-text").setup({})

			-- breakpoint 표시가 기본 'B' 텍스트라 눈에 잘 안 띈다.
			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", numhl = "" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn", numhl = "" })
			vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticInfo", linehl = "Visual" })

			dap.adapters.lldb = {
				type = "executable",
				command = lldb_dap_path(),
				name = "lldb",
			}

			-- 실행 파일 경로를 매번 묻는다. <Space> 빌드 키맵이 <프로젝트>/build/bin/<타깃> 에
			-- 떨구므로(lua/config/cppbuild.lua) 그게 기본값.
			local function pick_program()
				local default = require("config.cppbuild").dap_program()
				return coroutine.create(function(co)
					vim.ui.input({
						prompt = "실행 파일 경로: ",
						default = default,
						completion = "file",
					}, function(input)
						coroutine.resume(co, input)
					end)
				end)
			end

			local cpp_config = {
				{
					name = "실행 파일 디버그",
					type = "lldb",
					request = "launch",
					program = pick_program,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = {},
				},
			}

			dap.configurations.cpp = cpp_config
			dap.configurations.c = cpp_config
			dap.configurations.rust = cpp_config

			-- 세션 시작/종료에 맞춰 UI 자동 개폐
			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
		end,
	},
}

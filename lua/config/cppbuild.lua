-- CMake 기반 C/C++ 빌드 & 실행.
--
-- 예전 방식은 현재 파일 하나만 g++ 로 컴파일해서 /tmp 에 떨궜다. 파일이 여러 개인
-- 프로젝트를 다룰 수 없고, 재부팅하면 산출물이 사라지고, 이름이 같은 main.cpp 끼리
-- /tmp/main 을 서로 덮어썼다. 이제는 프로젝트 루트의 CMakeLists.txt 를 찾아
-- <루트>/build 안에서 빌드하고, 실행 파일은 <루트>/build/bin 에 모은다.

local M = {}

-- 프로젝트마다 실행할 타깃을 기억해 둔다. add_executable 이 여러 개인 프로젝트에서
-- 매번 고르라고 묻지 않기 위한 캐시. :CppTarget 으로 다시 고를 수 있다.
M.target_cache = {}

local function readlines(path)
	local f = io.open(path, "r")
	if not f then
		return {}
	end
	local lines = {}
	for line in f:lines() do
		lines[#lines + 1] = line
	end
	f:close()
	return lines
end

--- 버퍼가 속한 CMake 프로젝트의 루트를 찾는다.
--- 상위로 올라가며 CMakeLists.txt 가 있는 가장 바깥 디렉터리를 쓴다. add_subdirectory 로
--- 묶인 하위 프로젝트에서 <Space> 를 눌러도 최상위 프로젝트가 빌드되도록 하기 위함이다.
--- 홈 디렉터리 위로는 올라가지 않는다.
---@param path string? 기준 경로(기본: 현재 버퍼)
---@return string? root
function M.root(path)
	path = path or vim.api.nvim_buf_get_name(0)
	if path == "" then
		return nil
	end
	local home = vim.uv.os_homedir()
	local found = vim.fs.find("CMakeLists.txt", {
		upward = true,
		path = vim.fs.dirname(path),
		type = "file",
		limit = math.huge,
	})
	local root
	for _, hit in ipairs(found) do -- 가까운 것부터 먼 순서로 온다
		local dir = vim.fs.dirname(hit)
		if dir == home or not vim.startswith(dir, home) then
			break
		end
		root = dir
	end
	return root
end

--- CMakeLists.txt 를 훑어 실행 가능한 타깃 이름을 모은다.
--- CMake 를 실제로 돌리지 않고 텍스트만 읽으므로 완벽하진 않지만, add_executable /
--- add_subdirectory 를 따라가는 것만으로 보통의 프로젝트는 충분히 커버된다.
---@param root string
---@return string[]
function M.targets(root)
	local names, seen = {}, {}

	local function scan(dir, vars, depth)
		if depth > 6 then
			return
		end
		for _, raw in ipairs(readlines(dir .. "/CMakeLists.txt")) do
			local line = raw:gsub("#.*", "")

			local proj = line:match("^%s*[Pp]roject%s*%(%s*([%w_%-%.]+)")
			if proj then
				vars.PROJECT_NAME = proj
			end

			local exe = line:match("^%s*add_executable%s*%(%s*([%${}%w_%-%.]+)")
			-- IMPORTED/ALIAS 는 빌드 산출물이 없는 선언이라 실행 대상이 아니다
			if exe and not line:match("IMPORTED") and not line:match("ALIAS") then
				local name = exe:gsub("%${([%w_]+)}", function(v)
					return vars[v] or ""
				end)
				if name ~= "" and not seen[name] then
					seen[name] = true
					names[#names + 1] = name
				end
			end

			local sub = line:match("^%s*add_subdirectory%s*%(%s*([%w_%-%./]+)")
			if sub then
				scan(dir .. "/" .. sub, vim.tbl_extend("force", {}, vars), depth + 1)
			end
		end
	end

	scan(root, {}, 1)
	return names
end

--- 빌드된 실행 파일 경로. CMAKE_RUNTIME_OUTPUT_DIRECTORY 를 build/bin 으로 고정하므로
--- 타깃 이름만 알면 경로가 정해진다.
function M.exe(root, target)
	return root .. "/build/bin/" .. target
end

--- 프로젝트에 CMakeLists.txt 를 만든다.
--- GLOB 대신 소스 목록을 나열한다. GLOB 은 파일을 새로 추가해도 재구성이 안 걸려서
--- "왜 안 빌드되지" 하는 함정이 된다.
---@param dir string
---@return string project_name
function M.scaffold(dir)
	local name = vim.fs.basename(dir):gsub("[^%w_]", "_")
	if name:match("^%d") then
		name = "p" .. name -- CMake 타깃 이름은 숫자로 시작하지 않는 편이 안전하다
	end

	local sources = {}
	for _, pat in ipairs({ "*.cpp", "*.cc", "*.cxx", "*.c", "src/*.cpp", "src/*.cc", "src/*.cxx", "src/*.c" }) do
		for _, file in ipairs(vim.fn.glob(dir .. "/" .. pat, false, true)) do
			sources[#sources + 1] = file:sub(#dir + 2)
		end
	end
	if #sources == 0 then
		sources = { "main.cpp" }
	end
	table.sort(sources)

	local has_c = false
	for _, src in ipairs(sources) do
		if src:match("%.c$") then
			has_c = true
		end
	end

	local lines = {
		"cmake_minimum_required(VERSION 3.20)",
		("project(%s LANGUAGES %s)"):format(name, has_c and "C CXX" or "CXX"),
		"",
		"set(CMAKE_CXX_STANDARD 20)",
		"set(CMAKE_CXX_STANDARD_REQUIRED ON)",
		"# GNU 확장(-std=gnu++20) 대신 순수 표준(-std=c++20) 으로 컴파일한다.",
		"set(CMAKE_CXX_EXTENSIONS OFF)",
	}
	if has_c then
		vim.list_extend(lines, {
			"set(CMAKE_C_STANDARD 17)",
			"set(CMAKE_C_STANDARD_REQUIRED ON)",
			"set(CMAKE_C_EXTENSIONS OFF)",
		})
	end
	vim.list_extend(lines, {
		"",
		"# clangd 가 읽는 컴파일 DB. 켜 두면 헤더 경로/표준 설정이 에디터와 그대로 맞는다.",
		"set(CMAKE_EXPORT_COMPILE_COMMANDS ON)",
		"",
		"# 모든 타깃이 같은 경고 설정을 쓴다. 타깃을 추가하면 아래 target_compile_options 도",
		"# 같이 적어 줘야 한다.",
		"# -Weffc++ 는 Apple Clang 이 인자로 받아 주기만 하고 실제 진단은 내지 않는다(no-op).",
		"# GCC 로 빌드할 때를 대비해 남겨 둔다.",
		"# -Werror 는 경고를 빌드 실패로 승격시킨다. 서드파티 헤더 때문에 걸리면 -Werror 를",
		"# 빼는 대신 해당 include 경로를 SYSTEM 으로 표시할 것.",
		"set(PROJECT_WARNINGS",
		"\t-Wall",
		"\t-Weffc++",
		"\t-Wextra",
		"\t-Wconversion",
		"\t-Wsign-conversion",
		"\t-Werror",
		"\t-g",
		")",
		"",
		"# 소스를 추가하면 여기에 파일 이름을 적는다. file(GLOB) 은 파일 추가 시",
		"# 재구성이 걸리지 않아 일부러 쓰지 않는다.",
		"# main() 을 가진 파일마다 별도의 실행 파일 타깃이 필요하다.",
		("add_executable(%s"):format(name),
	})
	for _, src in ipairs(sources) do
		lines[#lines + 1] = "\t" .. src
	end
	vim.list_extend(lines, {
		")",
		"",
		("target_compile_options(%s PRIVATE ${PROJECT_WARNINGS})"):format(name),
		"",
	})

	vim.fn.writefile(lines, dir .. "/CMakeLists.txt")

	-- 빌드 산출물이 저장소에 딸려 들어가지 않도록
	local gitignore = dir .. "/.gitignore"
	if not vim.uv.fs_stat(gitignore) then
		vim.fn.writefile({ "build/", "compile_commands.json", ".cache/", "" }, gitignore)
	end

	return name
end

-- 실행 중이던 빌드 터미널은 하나만 유지한다. 누를 때마다 새로 만들면 숨은 터미널이 쌓인다.
local term

--- configure(필요할 때만) → build → run 을 한 줄짜리 셸 명령으로 엮는다.
--- && 로 이어 두면 컴파일이 실패했을 때 실행까지 가지 않고 에러가 그대로 남는다.
function M.shell_command(root, target)
	local build = root .. "/build"
	local sh = vim.fn.shellescape
	local steps = {}

	-- CMakeCache.txt 가 있으면 configure 는 생략한다. CMakeLists.txt 가 바뀐 경우는
	-- cmake --build 가 알아서 재구성을 걸어 준다.
	if not vim.uv.fs_stat(build .. "/CMakeCache.txt") then
		local args = {
			"cmake",
			"-S",
			sh(root),
			"-B",
			sh(build),
			"-DCMAKE_BUILD_TYPE=Debug",
			"-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
			"-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=" .. sh(build .. "/bin"),
		}
		-- 제너레이터는 최초 configure 에서만 정할 수 있다(캐시가 생기면 못 바꾼다).
		if vim.fn.executable("ninja") == 1 then
			args[#args + 1] = "-GNinja"
		end
		steps[#steps + 1] = table.concat(args, " ")
	end

	steps[#steps + 1] = ("cmake --build %s --target %s --parallel"):format(sh(build), sh(target))

	-- clangd 는 build/ 아래도 보지만, 루트에 링크가 있으면 어떤 상황에서도 확실하다.
	local link = root .. "/compile_commands.json"
	local stat = vim.uv.fs_lstat(link)
	if not stat or stat.type == "link" then
		steps[#steps + 1] = ("ln -sf %s %s"):format(sh("build/compile_commands.json"), sh(link))
	end

	steps[#steps + 1] = sh(M.exe(root, target))

	return table.concat(steps, " && ")
end

local function run(root, target)
	M.target_cache[root] = target

	if term then
		pcall(function()
			term:shutdown()
		end)
	end

	term = require("toggleterm.terminal").Terminal:new({
		cmd = M.shell_command(root, target),
		dir = root, -- 프로그램이 상대 경로로 파일을 열 때 프로젝트 루트가 기준이 되도록
		direction = "float",
		close_on_exit = false, -- 실행이 끝나도 결과를 볼 수 있게 남긴다
		on_open = function()
			vim.cmd("stopinsert")
		end,
	})
	term:open()
end

--- 타깃을 정한 뒤 콜백을 부른다. 캐시가 있으면 묻지 않는다.
local function with_target(root, force_pick, cb)
	if not force_pick and M.target_cache[root] then
		return cb(M.target_cache[root])
	end

	local targets = M.targets(root)
	if #targets == 0 then
		vim.notify(
			"CMakeLists.txt 에서 add_executable 을 찾지 못했습니다: " .. root,
			vim.log.levels.ERROR
		)
		return
	end
	if #targets == 1 and not force_pick then
		return cb(targets[1])
	end

	vim.ui.select(targets, { prompt = "실행할 타깃:" }, function(choice)
		if choice then
			cb(choice)
		end
	end)
end

--- <Space> 로 부르는 진입점. 저장 → (필요 시 configure) → 빌드 → 실행.
---@param opts table? { pick = true } 면 타깃을 다시 고른다
function M.build_and_run(opts)
	opts = opts or {}
	vim.cmd("write")

	local root = M.root()
	if root then
		return with_target(root, opts.pick, function(target)
			run(root, target)
		end)
	end

	-- CMake 프로젝트가 아니면 그 자리에서 만들 수 있게 물어본다.
	local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
	vim.ui.select({ "예", "아니오" }, {
		prompt = ("CMakeLists.txt 가 없습니다. %s 에 만들까요?"):format(vim.fn.fnamemodify(dir, ":~")),
	}, function(choice)
		if choice ~= "예" then
			return
		end
		local target = M.scaffold(dir)
		vim.notify("CMakeLists.txt 생성: " .. dir, vim.log.levels.INFO)
		run(dir, target)
	end)
end

--- nvim-dap 이 물어볼 때 채워 줄 기본 실행 파일 경로.
function M.dap_program()
	local root = M.root()
	if not root then
		return vim.fn.getcwd() .. "/"
	end
	local target = M.target_cache[root] or M.targets(root)[1]
	if not target then
		return root .. "/build/bin/"
	end
	return M.exe(root, target)
end

return M

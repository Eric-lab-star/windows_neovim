-- 프로젝트 루트를 먼저 잡는다. jdt.ls 는 root_dir 하나당 서버 하나 + `-data`
-- 워크스페이스 하나이므로 둘이 같은 기준에서 나와야 한다. 예전에는 workspace 만
-- getcwd() 로 뽑았는데, 그러면 nvim 을 어디서 띄웠느냐에 따라 같은 프로젝트가
-- 매번 다른 -data 를 잡거나 -- 더 나쁘게는 -- 서로 다른 프로젝트가 같은 -data 를
-- 공유해서 인덱스가 섞인다.
local root_dir = vim.fs.root(0, { '.git', 'mvnw', 'gradlew' }) or vim.fn.getcwd()
local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')

local workspace_dir = 'C:/Users/cyon2/Documents/source_code/java_workspace/' .. project_name

-- launcher jar 버전은 하드코딩하지 않는다. jdt.ls 를 재설치/업데이트하면 파일명이
-- 바뀌어 조용히 깨진다. `launcher_*` 는 플랫폼별 jar
-- (org.eclipse.equinox.launcher.win32.win32.x86_64_*.jar -- launcher 뒤가 '_' 가
-- 아니라 '.' 이다) 와는 겹치지 않아서 정확히 하나만 잡힌다.
local jdtls_home = 'C:/Users/cyon2/AppData/Local/nvim/jdtls'
local launcher = vim.fn.glob(jdtls_home .. '/plugins/org.eclipse.equinox.launcher_*.jar', true, true)[1]
if not launcher then
  vim.notify('jdtls: equinox launcher jar not found under ' .. jdtls_home .. '/plugins', vim.log.levels.ERROR)
  return
end
-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
  -- The command that starts the language server
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  cmd = {

    -- NOT bare 'java'. PATH/JAVA_HOME point at openjdk 26, and this jdt.ls
    -- build cannot run on it: the ASM bundled in aries-spifly cannot read
    -- Java 26 class files, so org.eclipse.m2e.core fails to activate and the
    -- server dies during startup with exit code 13:
    --
    --   java.lang.IllegalArgumentException: Unsupported class file major
    --   version 70                       (70 = Java 26; 65 = Java 21)
    --     at org.objectweb.asm.ClassReader.<init>
    --     at org.eclipse.m2e.core.internal.URLConnectionCaches.<clinit>
    --
    -- The trace surfaces only in <workspace>/.metadata/.log -- nvim just
    -- reports "Client jdtls quit with exit code 13".
    --
    -- corretto-jdk is 21.0.12 LTS, which is what jdt.ls wants. This picks the
    -- JVM the *server* runs on; it does not constrain the Java version a
    -- project compiles against.
    'C:/Users/cyon2/scoop/apps/corretto-jdk/current/bin/java.exe',

    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    -- 위에서 glob 으로 찾은 경로. 버전 문자열을 여기 박아두지 않는다.
    '-jar', launcher,

    -- 이 설치본의 OSGi 설정 디렉터리. Windows 이므로 config_win.
    '-configuration', jdtls_home .. '/config_win',


    -- 💀
    -- See `data directory configuration` section in the README
    '-data', workspace_dir,
  },

  -- 💀
  -- This is the default if not provided, you can remove it. Or adjust as needed.
  -- One dedicated LSP server & client will be started per unique root_dir
  --
  -- 위에서 이미 계산했다. workspace_dir 과 반드시 같은 값에서 나와야 한다.
  root_dir = root_dir,

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options

  -- Language server `initializationOptions`
  -- You need to extend the `bundles` with paths to jar files
  -- if you want to use additional eclipse.jdt.ls plugins.
  --
  -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
  --
  -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
  init_options = {
    bundles = {}
  },
}
-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require('jdtls').start_or_attach(config)

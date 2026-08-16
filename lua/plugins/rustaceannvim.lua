-- v5 -> v9 (2026-08). v5 는 2025-03 에 멈춘 핀이었고 그 사이 메이저가 넷 지났다.
-- 넘어오면서 걸리는 breaking change 는 전부 확인했고, 이 설정에 실제로 영향을
-- 주는 건 없었다:
--
--   v6  nvim 0.10 지원 중단          -> 0.12.4 라 무관
--       config.tools.edition 삭제     -> 쓰지 않음
--       rust-analyzer.json 지원 삭제  -> 쓰지 않음
--       LSP capabilities 자동 등록 중단
--         -> blink.cmp 가 plugin/blink-cmp.lua 에서 vim.lsp.config('*') 로
--            capabilities 를 전역 등록하고, rustaceanvim 이 그걸 병합해 간다.
--            (아래 주석 참고: snippet/resolve 지원이 실제로 붙는 걸 확인함)
--   v7  ra-multiplex 지원 삭제        -> 쓰지 않음 (lspmux 로 대체됨)
--   v8  .vscode/settings.json 지원 삭제
--         -> 쓰지 않음. 필요해지면 codesettings.nvim 을 따로 붙여야 한다.
--   v9  nvim 0.11 지원 중단           -> 0.12+ 필요. 0.12.4 라 무관
--
-- rust-analyzer 는 rustup 쪽(~/.cargo/bin/rust-analyzer.exe)을 자동으로 잡는다.
return {
	'mrcjkb/rustaceanvim',
	version = '^9',
	lazy = false, -- 플러그인 자체가 이미 lazy 하다 (ftplugin 으로 동작)
}

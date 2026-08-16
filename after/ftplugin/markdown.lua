-- buffer = true 가 필수다. ftplugin 안이라도 vim.keymap.set 은 기본이 전역
-- 매핑이라, 이게 없으면 markdown 을 한 번 여는 순간 그 세션 내내 *모든* 버퍼에서
-- j/k 가 gj/gk 로 바뀐다.
vim.keymap.set({ "n", "x" }, "k", "gk", { buffer = true })
vim.keymap.set({ "n", "x" }, "j", "gj", { buffer = true })

vim.b.undo_ftplugin = (vim.b.undo_ftplugin and vim.b.undo_ftplugin .. " | " or "")
	.. "silent! nunmap <buffer> k | silent! nunmap <buffer> j"
	.. " | silent! xunmap <buffer> k | silent! xunmap <buffer> j"

-- MDX 하이라이트. 전용 tree-sitter 파서가 없어서(nvim-treesitter 에 mdx 가
-- 아예 없다) markdown 파서에 얹는 방식이고, 이 플러그인이 하는 일은 셋뿐이다:
--
--   1. `.mdx` 를 filetype `mdx` 로 등록      -- 없으면 filetype 이 빈 문자열이라
--                                              LSP 도 treesitter 도 붙을 자리가 없다
--   2. mdx -> markdown 파서 별칭 등록
--   3. FileType mdx 에서 vim.treesitter.start(buf, "markdown")
--
-- 3번이 중요하다. nvim-treesitter master 브랜치는 저걸 자동으로 해줬지만 main
-- 브랜치 재작성 이후로는 안 해준다(treeSitter.lua 가 main 을 쓴다).
--
-- 얹어주는 injection 쿼리 덕에 import/export 줄과 `<Component>` 블록이
-- typescript/tsx 로 칠해진다 -- 필요한 markdown/tsx/typescript 파서는
-- treeSitter.lua 에서 이미 설치된다.
--
-- 주의: 쿼리가 after/queries/markdown/ 에 있어서 mdx 전용이 아니라 markdown
-- 파서 전체에 얹힌다. 일반 .md 에서도 `<` 로 시작하는 들여쓰기 블록이 tsx 로
-- 칠해질 수 있다.
--
-- LSP 는 여기 없다. mdx_analyzer 는 lsp.lua 의 servers 표에 있다.
return {
	"davidmh/mdx.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	-- filetype 등록이 after/plugin 에서 일어나므로 지연 로드하지 않는다.
	lazy = false,
}

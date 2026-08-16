-- 이걸 직접 쓰는 곳은 없다. barbar / lualine / nvim-tree / oil /
-- render-markdown 의 dependency 로만 불린다. lazy = true 를 주면 그 중 하나가
-- 로드될 때 따라 붙고, 아무도 안 부르면 아예 로드되지 않는다.
return {
	{ 'nvim-tree/nvim-web-devicons', lazy = true }
}

return {
    'MeanderingProgrammer/render-markdown.nvim',
    -- 아래 file_types 와 같은 목록. 이게 없으면 시작할 때 로드되면서
    -- nvim-web-devicons 까지 같이 끌고 온다.
    ft = { 'markdown', 'mdx' },
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    -- file_types 기본값은 { 'markdown' } 뿐이다. mdx.nvim 이 .mdx 의 filetype 을
    -- 'mdx' 로 잡아주는 순간 여기서 빠지므로 명시해야 한다.
    opts = {
        file_types = { 'markdown', 'mdx' },
    },
}

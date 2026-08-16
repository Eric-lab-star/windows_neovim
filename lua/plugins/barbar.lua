return  {
	'romgrk/barbar.nvim',
    -- bufferline 도 statusline 과 마찬가지로 첫 화면 이후에 붙어도 된다.
    -- init 의 barbar_auto_setup = false 는 lazy 여부와 무관하게 시작 시 실행되므로
    -- 그대로 유효하고, config/lazy.lua 의 <cmd>BufferPrevious<cr> 류 매핑은
    -- VeryLazy 시점이면 이미 명령이 존재한다.
    event = "VeryLazy",
    dependencies = {
      -- Needs opts so lazy.nvim actually calls setup(); as a bare string it was
      -- loaded but never initialised, so neither gitsigns nor barbar's git
      -- status showed anything.
      { 'lewis6991/gitsigns.nvim', opts = {} },
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
    init = function() vim.g.barbar_auto_setup = false end,
    opts = {
      -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
      -- animation = true,
      -- insert_at_start = true,
      -- …etc.
    },
    version = '^1.0.0', -- optional: only update when a new 1.x version is released
}

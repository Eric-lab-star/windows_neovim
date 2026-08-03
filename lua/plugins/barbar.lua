return  {
	'romgrk/barbar.nvim',
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

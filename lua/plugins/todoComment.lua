return {
  "folke/todo-comments.nvim",
  -- 버퍼가 열릴 때 하이라이트만 붙이면 되므로 시작 시점에 있을 필요가 없다.
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
  }
}

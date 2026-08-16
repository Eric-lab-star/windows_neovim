return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  -- config/lazy.lua 의 <C-g>g 가 <CMD>NvimTreeFindFile<CR> 라서, lazy.nvim 이
  -- 만들어두는 스텁 명령이 그대로 진입점이 된다. 매핑은 손댈 필요가 없다.
  --
  -- 참고: lazy = false 를 뺐으므로 디렉터리를 열 때(`nvim .`) nvim-tree 가
  -- 가로채지 않는다. netrw 는 이미 꺼져 있고 oil 이 eager 라서 oil 이 받는다 --
  -- 사실상 지금까지도 그랬다.
  cmd = {
    "NvimTreeFindFile",
    "NvimTreeToggle",
    "NvimTreeOpen",
    "NvimTreeClose",
    "NvimTreeFocus",
    "NvimTreeRefresh",
    "NvimTreeCollapse",
  },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup {}
  end,
}

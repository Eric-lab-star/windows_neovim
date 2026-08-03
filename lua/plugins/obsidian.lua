-- Migrated from epwalsh/obsidian.nvim (archived 2024-12) to the maintained
-- community fork. Completion is now served over an in-process LSP, so the
-- blink.compat 'obsidian*' sources are gone -- blink's 'lsp' source covers it.
return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  event = {
    "BufReadPre **/obsidian_vaults/*.md",
    "BufNewFile **/obsidian_vaults/*.md",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    -- Opt in to the `:Obsidian <subcommand>` form; the old one-command-per-action
    -- style is dropped in the fork's next major release.
    legacy_commands = false,

    workspaces = {
      {
        name = "personal",
        path = "~/obsidian_vaults",
      },
    },

    daily_notes = {
      enabled = true,
      -- Optional, if you keep daily notes in a separate directory.
      folder = "notes/dailies",
      -- Optional, if you want to change the date format for the ID of daily notes.
      date_format = "%Y-%m-%d",
      -- Moment-style tokens: the old "%B %-d, %Y" used %-d, a glibc extension
      -- that is not supported by Windows strftime.
      alias_format = "MMMM D, YYYY",
      -- Optional, default tags to add to each new daily note created.
      default_tags = { "daily-notes" },
      -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
      template = nil,
    },

    -- Optional, customize how note IDs are generated given an optional title.
    ---@param title string|?
    ---@return string
    note_id_func = function(title)
      -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
      -- In this case a note with the title 'My new note' will be given an ID that looks
      -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
      local suffix = ""
      if title ~= nil then
        -- If title is given, transform it into valid file name.
        suffix = title:gsub(" ", "-")
      else
        -- If title is nil, just add 4 random uppercase letters to the suffix.
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return tostring(os.time()) .. "-" .. suffix
    end,

    -- Replaces the deprecated wiki_link_func / markdown_link_func. "wiki" +
    -- "shortest" reproduces what wiki_link_id_prefix used to produce.
    link = {
      style = "wiki",
      format = "shortest",
    },

    -- follow_url_func is deprecated; the plugin now calls vim.ui.open itself,
    -- which also avoids the old `!start` shell-out mangling URLs that contain '&'.

    -- render-markdown.nvim is already installed and handles markdown display;
    -- leaving both on makes them fight over concealment.
    ui = { enable = false },
  },
}

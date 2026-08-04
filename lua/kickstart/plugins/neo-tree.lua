-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

vim.pack.add {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

vim.keymap.set('n', '\\', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })

-- Nerd Font が無い環境ではデフォルトのグリフが豆腐になり、しかも表示幅が
-- 1桁ずれて区切り線がガタつく。フォントの有無でアイコン一式を切り替える。
--  (`vim.g.have_nerd_font` は init.lua の SECTION 1 で定義)
local icons = vim.g.have_nerd_font
    and {
      folder_closed = '',
      folder_open = '',
      folder_empty = '󰉖',
      default = '',
    }
  or {
    folder_closed = '+',
    folder_open = '-',
    folder_empty = '.',
    default = ' ',
  }

local git_symbols = vim.g.have_nerd_font and {} or {
  added = 'A',
  modified = 'M',
  deleted = 'D',
  renamed = 'R',
  untracked = '?',
  ignored = 'i',
  unstaged = '!',
  staged = 'S',
  conflict = 'C',
}

require('neo-tree').setup {
  default_component_configs = {
    icon = icons,
    git_status = { symbols = git_symbols },
  },
  filesystem = {
    -- 隠しファイルを表示する。`.env` は gitignore されていることが多いので
    -- hide_dotfiles だけでは足りず hide_gitignored も落とす必要がある。
    filtered_items = {
      visible = true, -- フィルタ対象を「隠す」のではなく淡色で表示する
      hide_dotfiles = false,
      hide_gitignored = false,
      -- 閲覧する意味がないものだけ常に出さない。
      --  `hide_by_name` ではダメ。あれは visible = true だと淡色で表示されてしまう
      --  (defaults.lua:541 "they will just be displayed differently")。
      --  never_show はスキャン段階で除外されるので visible に関係なく消える。
      never_show = { '.DS_Store', '.git' },
    },
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
}

-- 起動時に自動で開く。
--  `focus` ではなく `show` を使う。focus だとカーソルがツリー側に移り、
--  ダッシュボードのショートカット (f/g/i/p など) が押せなくなる。
--  VimEnter の時点ではまだ UI が確定していないので schedule で1テンポ遅らせる。
vim.api.nvim_create_autocmd('VimEnter', {
  desc = 'Open neo-tree on startup',
  callback = function()
    vim.schedule(function() vim.cmd 'Neotree show' end)
  end,
})

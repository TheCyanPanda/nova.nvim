-- Set <space> as the leader key
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- vim.lsp.set_log_level 'debug'
-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Set default shell
-- vim.opt.shell = 'zsh'
vim.opt.guifont = 'JetBrainsMono Nerd Font:h12'

-- [[ Setting options ]]
-- NOTE:For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Set ethel root
vim.env.ETHEL_ROOT = '<cmd> getcwd()<CR>'
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
  pattern = { '*.c', '*.h', '*.py' },
  command = 'let $ETHEL_ROOT = getcwd()',
})

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true
-- Folding setup
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldcolumn = '1'
vim.opt.foldtext = ''
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 3
vim.opt.foldnestmax = 3

-- Save undo history
vim.opt.undofile = true

-- Auto-reselect visual mode after certain operations
vim.api.nvim_set_keymap('x', '<silent> <expr> <Plug>StayInVisual', 'v:lua.StayInVisual()', { noremap = true, silent = true })

function _G.StayInVisual()
  vim.schedule(function()
    vim.cmd 'normal! gv' -- Reselct the previous visual area
  end)
  return '<Plug>(nvim_exec)'
end

vim.api.nvim_set_keymap('x', '<Plug>(nvim_exec)', '', {})

-- Custom function to move the current line to the far left or append to the line above
function MoveLineLeftOrRight()
  local current_line = vim.fn.line '.' -- Get the current line number
  local line_above = current_line - 1 -- Get the line number above the current one
  local line_above_text = vim.fn.getline(line_above) -- Get the content of the line above
  local rightmost_char_col = #line_above_text -- Get the rightmost column on the line above

  -- If the current line is on the far left and the line above is non-empty, append it to the rightmost character of the line above
  if vim.fn.getline(current_line):match '^%s*$' then
    return -- Do nothing if the current line is empty
  end

  -- If the current line has only whitespace, move it to the rightmost column of the line above
  if vim.fn.getline(current_line):match '^%s+' then
    -- Move the current line next to the rightmost character of the line above
    vim.fn.setline(line_above, line_above_text .. ' ' .. vim.fn.getline(current_line):gsub('^%s+', '')) -- Append the current line to the line above
    vim.cmd 'normal! dd' -- Delete the current line after moving it
  else
    -- Move the current line to the far left (remove leading whitespace)
    vim.cmd 'normal! ^'
    vim.cmd 'normal! "_d0' -- Delete leading whitespace
  end
end

-- Local functions --
function python_shebang()
  local pos = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local nline = line:sub(0, pos) .. '#!/usr/bin/env python3' .. line:sub(pos + 1)
  vim.api.nvim_set_current_line(nline)
end

-- Custom keybindings
-- Resize split (Ctrl + Shift + Right Arrow)
vim.api.nvim_set_keymap('n', '<A-Left>', ':vertical resize -5<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-Right>', ':vertical resize +5<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-Up>', ':horizontal resize +5<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-Down>', ':horizontal resize -5<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<A-Up>', '<C-\\><C-n>:horizontal resize +5<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<A-Down>', '<C-\\><C-n>:horizontal resize -5<CR>', { noremap = true, silent = true })
-- Exit terminal mode with ESC
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true })
-- Allow CTRL+w to be used in terminal mode
vim.api.nvim_set_keymap('t', '<C-w>', '<C-\\><C-n><C-w>', { noremap = true, silent = true })
-- Move selected text down (Alt + j)
vim.api.nvim_set_keymap('v', '<A-j>', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
-- Move selected text up (Alt + k)
vim.api.nvim_set_keymap('v', '<A-k>', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
-- Move current line down (Alt + j)
vim.api.nvim_set_keymap('n', '<A-j>', ':m .+1<CR>==', { noremap = true, silent = true })
-- Move current line up (Alt + k)
vim.api.nvim_set_keymap('n', '<A-k>', ':m .-2<CR>==', { noremap = true, silent = true })
-- Move current line to line on top
vim.api.nvim_set_keymap('n', '<A-h>', ':lua MoveLineLeftOrRight()<CR>', { noremap = true, silent = true })

-- LSP signature help
vim.api.nvim_set_keymap('n', '<F1>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<F1>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', { noremap = true, silent = true })

-- Trigger completion
vim.api.nvim_set_keymap('i', '<C-Space>', '<cmd>lua require("cmp").complete()<CR>', { noremap = true, silent = true })

-- Custom Python functions
-- Add python shebang
vim.api.nvim_set_keymap('n', '<leader>kp', '<cmd>lua python_shebang()<CR>', { noremap = true, silent = true })
-- Create f-string for debugging variables
vim.keymap.set('n', '<leader>kf', function()
  vim.api.nvim_put({ 'print(f"{=}")' }, 'c', true, true) -- Insert the text
  vim.cmd 'normal! F=a' -- Move to the '{' and enter insert mode before the '='
end, { desc = "Insert print('{=}') with cursor inside" })

-- Run Flake8 on the current file with F7
vim.api.nvim_set_keymap(
  'n',
  '<F7>',
  ':!flake8 --max-line-length=100 --ignore=DAR101,DAR201,DAR401,DAR103,E231,FNE005,FNE008,N802,DAR102,DAR003 %:p<CR>',
  { noremap = true, silent = true }
)

-- Buffer management
vim.api.nvim_set_keymap('n', '<C-w>C', ':b#|bd#<CR>', { noremap = true, silent = true }) -- Close current buffer but keep window alive
vim.api.nvim_set_keymap('n', '<C-w>h', ':BufferLineCyclePrev<CR>', { noremap = true, silent = true }) -- Go to previous buffer
vim.api.nvim_set_keymap('n', '<C-w>l', ':BufferLineCycleNext<CR>', { noremap = true, silent = true }) -- Go to next buffer
vim.api.nvim_set_keymap('n', '<C-w>x', ':BufferKill<CR>', { noremap = true, silent = true }) -- Close current window

-- Visual mode search and replace string
vim.keymap.set('v', 'w', ':s/\\%V', { desc = 'Search and replace string' })

-- Shift-HOME to go to the beginning of the line in insert mode
vim.keymap.set('i', '<S-Home>', '<C-o>^', { noremap = true, silent = true })
vim.keymap.set('n', '<S-Home>', '^', { noremap = true, silent = true })

-- Formatting with Ruff manually
vim.api.nvim_set_keymap('n', '<leader>kr', ':lua vim.lsp.buf.formatting_sync()<CR>', { noremap = true, silent = true })

-- Telescope mappings
vim.api.nvim_set_keymap('n', '<leader>Tf', ':Telescope live_grep<CR>', { noremap = true, silent = true }) -- Search for string in folder
vim.api.nvim_set_keymap('n', '<leader>Tg', ':Telescope grep_string<CR>', { noremap = true, silent = true }) -- Search for word under cursor
vim.api.nvim_set_keymap('n', '<leader>Tp', ':Telescope find_files<CR>', { noremap = true, silent = true }) -- Find files
vim.api.nvim_set_keymap('n', '<leader>Tr', ':Telescope current_buffer_fuzzy_find<CR>', { noremap = true, silent = true }) -- Fuzzy find in current buffer
vim.api.nvim_set_keymap('n', '<leader>Tb', ':Telescope buffers<CR>', { noremap = true, silent = true }) -- List open buffers
vim.api.nvim_set_keymap(
  'n',
  '<leader>TR',
  [[:lua require('telescope.builtin').current_buffer_fuzzy_find({ default_text = vim.fn.expand("<cword>") })<CR>]],
  { noremap = true, silent = true }
) -- Search for word under cursor in current buffer

-- Show full path of current file
vim.api.nvim_set_keymap('n', '<leader>ss', ":echo expand('%:p')<CR>", { noremap = true, silent = true })

-- Toggle diagnostics
vim.api.nvim_set_keymap('n', '<leader>td', ':Trouble diagnostics<CR>', { noremap = true, silent = true })

-- Custom options
vim.opt.colorcolumn = '100' -- Set the color column to highlight at 100 characters

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.listchars = {
  tab = '  →',
  space = '·',
  trail = '·',
  nbsp = 'x',
  precedes = '⇠',
  extends = '⇢',
}
vim.opt.list = true
vim.opt.tabstop = 4
vim.opt.expandtab = true

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- [[ Basic Autocommands ]]

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]

--  To check the current status of your plugins, run
--    :Lazy

require('lazy').setup {

  -- Detect tabstop and shiftwidth automatically
  {
    'tpope/vim-sleuth',
  },

  {
    -- Bufferline for showing open files
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons', -- optional, for file icons
    config = function()
      require('bufferline').setup {
        options = {
          numbers = 'buffer_id', -- Show buffer numbers
          close_command = 'bdelete! %d', -- Close buffers with the "x" button
          right_mouse_command = 'bdelete! %d', -- Close with right-click
          left_mouse_command = 'buffer %d', -- Switch to buffer with left-click
          middle_mouse_command = nil, -- Disable middle-click closing
          indicator = {
            style = 'icon',
            icon = '|', -- Use a vertical bar as an indicator
          },
          show_buffer_close_icons = true,
          show_close_icon = false,
          separator_style = 'slant', -- Different separator style between buffers
          diagnostics = 'nvim_lsp', -- Show diagnostics from LSP if any
        },
      }
    end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    version = 'v3.*',
    config = function()
      require('ibl').setup {
        indent = {
          char = '│', -- Character to show for each indentation level
          tab_char = '»', -- Optional: Character for tabs
        },
        scope = {
          enabled = true, -- Enable scope highlighting
          show_start = false,
          show_end = false,
        },
        exclude = { filetypes = { 'help', 'terminal', 'dashboard' } }, -- Exclude certain file types
      }
      vim.api.nvim_set_keymap('n', '<leader>i', ':IBLToggle<CR>', { noremap = true, silent = true })
    end,
  },
  -- Lualine
  -- | A | B | C                             X | Y | Z |
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup {
        sections = {
          -- Left status bar
          lualine_a = {
            {
              'mode',
              color = function()
                if vim.bo.modified then
                  return { bg = '#ff0000', fg = '#ffffff' } -- Red background when buffer is modified
                else
                  return { bg = nil, fg = nil } -- Default colors
                end
              end,
            },
          },
          -- left status bar
          -- lualine_b = {
          -- },
          -- Left status bar
          lualine_c = {
            -- Custom component for indentation level
            {
              function()
                local expandtab = vim.bo.expandtab
                local indent_type = expandtab and 'Spaces' or 'Tabs'
                local indent_size = vim.bo.shiftwidth
                return indent_type .. ': ' .. indent_size
              end,
              icon = ' ', -- Optional: Add an icon for visual appeal
            },
            'diagnostics',
            'filename',
          },
          -- Right status bar
          -- lualine_x = {
          -- },
          -- Right status bar
          lualine_y = {
            'searchcount',
            'selectioncount',
            'location',
          },

          -- Right status bar
          lualine_z = {
            {
              'mode',
              color = function()
                if vim.bo.modified then
                  return { bg = '#ff0000', fg = '#ffffff' } -- Red background when buffer is modified
                else
                  return { bg = nil, fg = nil } -- Default colors
                end
              end,
            },
          },
        },

        -- Other configuration options (optional)
        options = {
          theme = 'auto', -- You can change the theme here
          section_separators = '', -- Customize separators
          component_separators = '',
        },
      }
    end,
  },

  -- Git Conflict
  {
    'akinsho/git-conflict.nvim',
    version = '*',
    config = true,
  },

  -- LSP Signature
  {
    'ray-x/lsp_signature.nvim',
    config = function()
      require('lsp_signature').setup {
        bind = true,
        floating_window = true,
        hint_enable = true,
        hint_prefix = '',
        hi_parameter = 'LspSignatureActiveParameter',
      }
    end,
  },

  -- Clang Format
  {
    'rhysd/vim-clang-format',
  },

  -- Scrollbar
  {
    'petertriho/nvim-scrollbar',
    config = function()
      require('scrollbar').setup()
    end,
  },

  -- Smooth scrolling
  {
    'karb94/neoscroll.nvim',
    config = function()
      require('neoscroll').setup {}
    end,
  },

  -- Neogen (automatic documentation generation)
  {
    'danymat/neogen',
    config = true,
  },

  -- Python indentation
  {
    'Vimjas/vim-python-pep8-indent',
  },

  -- Symbols outline
  {
    'simrat39/symbols-outline.nvim',
    config = function()
      require('symbols-outline').setup()
      vim.keymap.set('n', '<F4>', ':SymbolsOutline<CR>', {})
    end,
  },

  -- Diffview
  {
    'sindrets/diffview.nvim',
    event = 'BufRead',
  },
  -- Diagnostics / errors/ warnings
  {
    'folke/trouble.nvim',
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = 'Trouble',
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>cs',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Symbols (Trouble)',
      },
      {
        '<leader>cl',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'LSP Definitions / references / ... (Trouble)',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>xQ',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix List (Trouble)',
      },
    },
  },

  -- Search Panel
  {
    'windwp/nvim-spectre',
    event = 'BufRead',
    config = function()
      require('spectre').setup()
      vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").toggle()<CR>', { desc = 'Toggle Spectre' })
      vim.keymap.set('n', '<leader>F', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', { desc = 'Search on current file' })
      vim.keymap.set('n', '<leader>G', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', { desc = 'Search current word' })
    end,
  },

  -- Vim fugitive (git plugin)
  {
    'tpope/vim-fugitive',
  },

  -- Mini trailspace
  { 'echasnovski/mini.trailspace', version = '*' },

  -- Whitespace plugin
  {
    'johnfrankmorgan/whitespace.nvim',
    config = function()
      require('whitespace-nvim').setup {
        highlight = 'DiffDelete',
        ignored_filetypes = { 'TelescopePrompt', 'Trouble', 'help', 'dashboard' },
        ignore_terminal = true,
        return_cursor = true,
      }
      vim.keymap.set('n', '<Leader>t', require('whitespace-nvim').trim)
    end,
  },

  -- LSP colors
  {
    'folke/lsp-colors.nvim',
    event = 'BufRead',
  },

  -- Mini map
  {
    'echasnovski/mini.map',
    branch = 'stable',
    config = function()
      require('mini.map').setup {
        integrations = {
          require('mini.map').gen_integration.builtin_search(),
          require('mini.map').gen_integration.diagnostic {
            error = 'DiagnosticFloatingError',
            warn = 'DiagnosticFloatingWarn',
            info = 'DiagnosticFloatingInfo',
            hint = 'DiagnosticFloatingHint',
          },
        },
        symbols = { encode = require('mini.map').gen_encode_symbols.dot '4x2' },
        window = { side = 'right', width = 20, winblend = 15, show_integration_count = false },
      }
      vim.keymap.set('n', '<Leader>mt', require('mini.map').toggle)
    end,
  },

  -- Goto Preview
  {
    'rmagatti/goto-preview',
    config = function()
      require('goto-preview').setup {
        width = 120,
        height = 25,
        default_mappings = false,
        debug = false,
        opacity = nil,
      }
      vim.keymap.set('n', '<F2>', "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", { noremap = true })
      vim.keymap.set('n', '<F3>', "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", { noremap = true })
    end,
  },
  -- Leap
  {
    'ggandor/leap.nvim',
    dependencies = { 'tpope/vim-repeat' },
    config = function()
      require('leap').add_default_mappings()
    end,
  },
  {
    'tpope/vim-repeat',
    lazy = false, -- Ensures repeat.nvim is always loaded
  },

  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
    config = function()
      require('gitsigns').setup()
      require('scrollbar.handlers.gitsigns').setup()
      vim.keymap.set('n', '<leader>gp', ':Gitsigns preview_hunk<CR>', {})
      vim.keymap.set('n', '<leader>gt', ':Gitsigns toggle_current_line_blame<CR>', {})
    end,
  },

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default whick-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      -- Document existing key chains
      spec = {
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },
  -- File manager --
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- optional, for icons
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('neo-tree').setup {
        filesystem = {
          follow_current_file = true, -- Opens the folder of the current file
          use_libuv_file_watcher = true, -- Auto-refresh
        },
      }
      -- Replace NvimTreeToggle keymap
      vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { noremap = true, silent = true })
    end,
  },

  { -- TELESCOPE  - Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      {
        'nvim-tree/nvim-tree.lua',
        version = '*',
        lazy = false,
        dependencies = {
          'nvim-tree/nvim-web-devicons',
        },
        config = function()
          require('nvim-tree').setup {}
        end,
      },
      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by nvim-cmp
      'hrsh7th/cmp-nvim-lsp',
    },
    flags = {
      debounce_text_changes = 500,
    },
    settings = {
      python = {
        analysis = {
          maxNumberOfProblems = 10000, -- Limit number of diagnostics shown
        },
      },
    },
    config = function()
      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }
    end,
  },

  -- Status column
  {
    'luukvbaal/statuscol.nvim',
    config = function()
      local builtin = require 'statuscol.builtin'
      require('statuscol').setup {}
    end,
  },
  -- QoL plugin (snacks)
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      -- your configuration comes here
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
    },
    keys = {
      {
        '<leader>gL',
        function()
          Snacks.lazygit()
        end,
        desc = 'Lazygit',
      },
      {
        '<leader>tt',
        function()
          Snacks.terminal()
        end,
        desc = 'Toggle Terminal',
      },
      {
        '<leader>gF',
        function()
          Snacks.lazygit.log_file()
        end,
        desc = 'Lazygit Current File History',
      },
    },
  },
  -- Auto comment out
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
      -- Keymap for commenting/uncommenting lines
      vim.api.nvim_set_keymap('n', '<leader>/', 'gcc', { noremap = false, silent = true }) -- Normal mode
      vim.api.nvim_set_keymap('v', '<leader>/', 'gc', { noremap = false, silent = true }) -- Visual mode
    end,
  },
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format_opt = 'never'
        else
          lsp_format_opt = 'fallback'
        end
        return {
          timeout_ms = 500,
          lsp_format = lsp_format_opt,
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },
  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-y>'] = cmp.mapping.confirm { select = true },

          -- If you prefer more traditional completion keymaps,
          -- you can uncomment the following lines
          ['<C-CR>'] = cmp.mapping.confirm { select = true },
          ['<CR>'] = cmp.mapping.abort(), -- Disable Enter for confirming
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          {
            name = 'lazydev',
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }
    end,
  },

  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'catppuccin-mocha'

      -- You can configure highlights by doing something like:
      vim.cmd.hi 'Comment gui=none'
    end,
  },
  -- Catppuccin theme
  { 'catppuccin/nvim' },

  -- Kanagawa theme
  { 'rebelot/kanagawa.nvim' },

  -- Nord theme
  { 'arcticicestudio/nord-vim' },

  -- Nightfox theme
  { 'EdenEast/nightfox.nvim' },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },
  -- Null-ls
  {
    'jose-elias-alvarez/null-ls.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'jay-babu/mason-null-ls.nvim', -- Integration with Mason
      'williamboman/mason.nvim', -- LSP and linter installer
    },
    config = function()
      local null_ls = require 'null-ls'
      null_ls.setup {
        -- sources = {
        --   null_ls.builtins.diagnostics.flake8.with {
        --     extra_args = { '--max-line-length', '100', '--ignore', 'DAR101,DAR201,DAR401,FNE005,FNE008,N802,DAR102,DAR003' },
        --   },
        -- },
      }
      -- Automatically install null-ls sources
      require('mason-null-ls').setup {
        -- ensure_installed = { 'flake8' }, -- Make sure Flake8 is installed
      }
    end,
  },

  -- Breadcrums
  {
    'Bekaboo/dropbar.nvim',
    -- optional, but required for fuzzy finder support
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
    config = function()
      local dropbar_api = require 'dropbar.api'
      vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
      vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
      vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    end,
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

-- SET UP LSP --
local lspconfig = require 'lspconfig'

require('lspconfig').clangd.setup {
  -- cmd = { 'clangd', }, -- Replace with your actual path
  on_attach = function(client, bufnr)
    -- Custom on_attach code here
  end,
}

lspconfig.rust_analyzer.setup {
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true,
      },
      checkOnSave = {
        command = 'clippy',
      },
    },
  },
}

lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file('', true),
      },
      telemetry = {
        -- Do not send telemetry data containing a unique identifier
        enable = false,
      },
    },
  },
}

lspconfig.pylsp.setup {
  settings = {
    pylsp = {
      plugins = {
        ruff = {
          enabled = true, -- Enable the plugin
          formatEnabled = false, -- Enable formatting using ruffs formatter
          -- config = '<path_to_custom_ruff_toml>', -- Custom config for ruff to use
          extendSelect = { 'ALL' }, -- Rules that are additionally used by ruff
          -- extendIgnore = { 'C90' }, -- Rules that are additionally ignored by ruff
          -- format = { 'I' }, -- Rules that are marked as fixable by ruff that should be fixed when running textDocument/formatting
          -- severities = { ['D212'] = 'I' }, -- Optional table of rules where a custom severity is desired
          unsafeFixes = false, -- Whether or not to offer unsafe fixes as code actions. Ignored with the "Fix All" action

          -- Rules that are ignored when a pyproject.toml or ruff.toml is present:
          lineLength = 100, -- Line length to pass to ruff checking and formatting
          -- exclude = { '__about__.py' }, -- Files to be excluded by ruff checking
          -- select = { 'F' }, -- Rules to be enabled by ruff
          ignore = {
            'FBT002',
            'FBT001',
            'I001',
            'D400',
            'D415',
            'D212',
            'D411',
            'D407',
            'D205',
            'D401',
            'D413',
            'D407',
            'D205',
            'D101',
            'D107',
            'Q000',
            'D204',
            'PLR0913',
            'T201',
            'D417',
            'COM812',
            'EXE001',
            'D406',
            'ANN204',
          }, -- Rules to be ignored by ruff
          -- perFileIgnores = { ['__init__.py'] = 'CPY001' }, -- Rules that should be ignored for specific files
          -- preview = false, -- Whether to enable the preview style linting and formatting.
          -- targetVersion = 'py310', -- The minimum python version to target (applies for both linting and formatting).
        },
        -- pycodestyle = { enabled = true, ignore = { 'W391' }, maxLineLength = 100 },
        -- pylint = { enabled = true, executable = 'pylint' },
        -- flake8 = { enabled = true, ignore = { 'DAR101,DAR201,DAR401,FNE005,FNE008,N802,DAR102,DAR003' }, maxLineLength = 100, indentsize = 4 },
        -- pyflakes = { enabled = false },
        mypy = { enabled = true, strict = true },
        jedi_completion = { enabled = true, fuzzy = true },
        isort = { enabled = true },
        pytypes = {
          enabled = true, -- Enable the pytypes plugin
          check_untyped_defs = true, -- Check for untyped function definitions
          suggest_type = true, -- Suggest types for functions or variables that lack annotations
        },
      },
    },
  },
}

-- Function to enable Pyright
function EnablePyright()
  lspconfig.pyright.setup {}
end

-- Function to disable Pyright
function DisablePyright()
  -- Get all active LSP clients
  local clients = vim.lsp.get_clients()
  for _, client in ipairs(clients) do
    -- Check if client is Pyright
    if client.name == 'pyright' then
      vim.lsp.stop_client(client.id)
    end
  end
end

-- Keybindings to toggle Pyright
vim.api.nvim_set_keymap('n', '<leader>le', ':lua EnablePyright()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ld', ':lua DisablePyright()<CR>', { noremap = true, silent = true })

-- Telescope Pyright integration

local Job = require 'plenary.job'
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local previewers = require 'telescope.previewers'
local actions = require 'telescope.actions'

-- Function to run a shell command and display results in a Telescope floating window
function run_command(command)
  local current_file = vim.api.nvim_buf_get_name(0) -- Get current buffer's file path

  -- If current file is empty, return (i.e., if it's a new unsaved buffer)
  if current_file == '' then
    print 'No file to run the command on!'
    return
  end

  -- Modify the command to include the current file (but you only want the file content processed by the command)
  local full_command = command .. ' ' .. current_file

  -- Start the job with the updated command
  Job:new({
    command = 'zsh', -- Use zsh to run the command
    args = { '-c', full_command }, -- Pass the full command to the shell
    on_exit = function(j, return_val)
      if return_val == 0 or return_val == 1 then
        local result = j:result()

        -- Strip out any file paths or extra info from the result
        local stripped_result = {}
        for _, line in ipairs(result) do
          -- Replace the full path with just the message (adjust depending on the command)
          local stripped_line = line:gsub(current_file, ''):gsub('^%s*(.-)%s*$', '%1') -- Removing file path
          table.insert(stripped_result, stripped_line)
        end

        -- Schedule the picker creation to run after the job completes
        vim.schedule(function()
          pickers
            .new({}, {
              prompt_title = 'Command Output',
              finder = finders.new_table {
                results = stripped_result,
              },
              previewer = previewers.new_buffer_previewer {
                define_preview = function(self, entry, status)
                  -- Set the buffer with the cleaned result
                  vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, stripped_result)

                  -- Set filetype to 'text' for generic output (could be customized based on command output)
                  vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', 'text')

                  -- Enable syntax highlighting if needed
                  vim.cmd 'syntax enable'
                end,
              },
              attach_mappings = function(_, map)
                map('i', '<CR>', actions.close)
                map('n', '<CR>', actions.close)
                return true
              end,
            })
            :find()
        end)
      else
        print 'Command execution failed'
      end
    end,
  }):start()
end

-- Set key mapping to trigger the run_command function with a placeholder command (e.g., pyright)
vim.api.nvim_set_keymap(
  'n',
  '<leader>kl',
  ':lua run_command("flake8 --max-line-length=100 --ignore=DAR101,DAR201,DAR401,DAR103,E231,FNE005,FNE008,N802,DAR102,DAR003")<CR>',
  { noremap = true, silent = true, desc = 'Run flake8' }
)

local null_ls = require 'null-ls'

null_ls.setup {
  -- This config makes sure diagnostics stay enabled regardless of file size
  on_attach = function(client, bufnr)
    -- Enable inline diagnostics for large files as well
    client.server_capabilities.documentFormattingProvider = true
    client.server_capabilities.documentRangeFormattingProvider = true
    vim.diagnostic.config {
      virtual_text = true, -- Show inline diagnostics (virtual text)
      signs = true,
      underline = true,
      update_in_insert = true,
    }
  end,
}

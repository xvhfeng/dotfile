-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/xuhaifeng/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/Users/xuhaifeng/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/Users/xuhaifeng/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/Users/xuhaifeng/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/xuhaifeng/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["FencView.vim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/FencView.vim",
    url = "https://github.com/vim-scripts/FencView.vim"
  },
  LeaderF = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/LeaderF",
    url = "https://github.com/Yggdroot/LeaderF"
  },
  ["LeaderF-floaterm"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/LeaderF-floaterm",
    url = "https://github.com/voldikss/LeaderF-floaterm"
  },
  Unimpaired = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/Unimpaired",
    url = "https://github.com/tpope/vim-unimpaired"
  },
  asyncrun = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/asyncrun",
    url = "https://github.com/skywind3000/asyncrun.vim"
  },
  asynctasks = {
    commands = { "AsyncTask" },
    config = { "\27LJ\2\nˆ\1\0\0\4\0\f\0\0286\0\0\0009\0\1\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\5\0B\0\2\0016\0\3\0009\0\6\0004\1\3\0006\2\3\0009\2\6\0029\2\b\2'\3\t\0&\2\3\2>\2\1\1=\1\a\0006\0\3\0009\0\6\0)\1\b\0=\1\n\0006\0\3\0009\0\6\0)\1\1\0=\1\v\0K\0\1\0\18asyncrun_bell\18asyncrun_open\14tasks.ini\vCONFIG\28asynctasks_extra_config\6g\21packadd asyncrun\bcmd\bvim\vloaded\rasyncrun\19packer_plugins\0" },
    loaded = true,
    only_cond = false,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/asynctasks",
    url = "https://github.com/cstsunfu/asynctasks.vim"
  },
  autojump = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/autojump",
    url = "https://github.com/trotter/autojump.vim"
  },
  automkdir = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/automkdir",
    url = "https://github.com/vim-scripts/auto_mkdir"
  },
  ["bclose.vim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/bclose.vim",
    url = "https://github.com/rbgrouleff/bclose.vim"
  },
  bufexplorer = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/bufexplorer",
    url = "https://github.com/jlanzarotta/bufexplorer"
  },
  ["context.vim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/context.vim",
    url = "https://github.com/wellle/context.vim"
  },
  ["deoplete.nvim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/deoplete.nvim",
    url = "https://github.com/Shougo/deoplete.nvim"
  },
  ["expand-region"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/expand-region",
    url = "https://github.com/terryma/vim-expand-region"
  },
  genutils = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/genutils",
    url = "https://github.com/vim-scripts/genutils"
  },
  ["indent-blankline"] = {
    config = { "\27LJ\2\næ\3\0\0\3\0\f\0\0236\0\0\0009\0\1\0005\1\3\0=\1\2\0006\0\0\0009\0\1\0005\1\5\0=\1\4\0006\0\0\0009\0\1\0)\1\4\0=\1\6\0006\0\0\0009\0\1\0+\1\1\0=\1\a\0006\0\b\0'\2\t\0B\0\2\0029\0\n\0005\2\v\0B\0\2\1K\0\1\0\1\0\2\25show_current_context\2\25space_char_blankline\6 \nsetup\21indent_blankline\frequire$indent_blankline_use_treesitter\"indent_blankline_indent_level\1\14\0\0\15translator\22dapui_breakpoints\18dapui_watches\17dapui_stacks\17dapui_scopes\5\thelp\vpacker\rstartify\14dashboard\fvimwiki\rmarkdown\rcalendar&indent_blankline_filetype_exclude\1\2\0\0\b‚îÇ\31indent_blankline_char_list\6g\bvim\0" },
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/indent-blankline",
    url = "https://github.com/lukas-reineke/indent-blankline.nvim"
  },
  ["mason-lspconfig.nvim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/mason-lspconfig.nvim",
    url = "https://github.com/williamboman/mason-lspconfig.nvim"
  },
  ["mason.nvim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/mason.nvim",
    url = "https://github.com/williamboman/mason.nvim"
  },
  material = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/material",
    url = "https://github.com/marko-cerovac/material.nvim"
  },
  nerdcommenter = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/nerdcommenter",
    url = "https://github.com/preservim/nerdcommenter"
  },
  ["nvim-hlslens"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/nvim-hlslens",
    url = "https://github.com/kevinhwang91/nvim-hlslens"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-spectre"] = {
    config = { "\27LJ\2\nô\1\0\0\3\0\t\0\0156\0\0\0009\0\1\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\5\0B\0\2\0016\0\6\0'\2\a\0B\0\2\0029\0\b\0B\0\1\1K\0\1\0\nsetup\fspectre\frequire\25packadd plenary.nvim\bcmd\bvim\vloaded\17plenary.nvim\19packer_plugins\0" },
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/nvim-spectre",
    url = "https://github.com/windwp/nvim-spectre"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/kyazdani42/nvim-web-devicons"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/popup.nvim",
    url = "https://github.com/nvim-lua/popup.nvim"
  },
  rainbow = {
    config = { "\27LJ\2\n\v\0\0\1\0\0\0\1K\0\1\0\0" },
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/rainbow",
    url = "https://github.com/luochen1990/rainbow"
  },
  ["ranger.vim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/ranger.vim",
    url = "https://github.com/francoiscabrol/ranger.vim"
  },
  ["sql.nvim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/sql.nvim",
    url = "https://github.com/tami5/sql.nvim"
  },
  ["sqlite.lua"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/sqlite.lua",
    url = "https://github.com/tami5/sqlite.lua"
  },
  ["telescope-frecency.nvim"] = {
    load_after = {},
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/telescope-frecency.nvim",
    url = "https://github.com/nvim-telescope/telescope-frecency.nvim"
  },
  ["telescope-fzf-native.nvim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim",
    url = "https://github.com/nvim-telescope/telescope-fzf-native.nvim"
  },
  ["telescope-project.nvim"] = {
    load_after = {},
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/telescope-project.nvim",
    url = "https://github.com/nvim-telescope/telescope-project.nvim"
  },
  ["telescope.nvim"] = {
    after = { "telescope-project.nvim", "telescope-frecency.nvim" },
    config = { "\27LJ\2\n”\1\0\1\a\2\a\0\26-\1\0\0009\1\0\1\18\3\0\0B\1\2\0026\2\1\0009\2\2\2\18\6\1\0009\4\3\1B\4\2\0A\2\0\2)\3\1\0\1\3\2\0X\3\bÄ-\3\1\0009\3\4\3\18\5\0\0B\3\2\1-\3\1\0009\3\5\3B\3\1\1X\3\4Ä-\3\1\0009\3\6\3\18\5\0\0B\3\2\1K\0\1\0\1¿\0¿\14file_edit\16open_qflist\28send_selected_to_qflist\24get_multi_selection\tgetn\ntable\23get_current_picker◊\16\1\0\n\0R\0ß\0016\0\0\0009\0\1\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\5\0B\0\2\0016\0\0\0009\0\6\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\a\0B\0\2\0016\0\0\0009\0\b\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\t\0B\0\2\0016\0\0\0009\0\n\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\v\0B\0\2\0016\0\0\0009\0\f\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\r\0B\0\2\0016\0\14\0'\2\15\0B\0\2\0026\1\14\0'\3\16\0B\1\2\0029\1\17\1'\3\18\0B\1\2\0016\1\14\0'\3\19\0B\1\2\0024\2\0\0003\3\21\0=\3\20\0026\3\14\0'\5\16\0B\3\2\0029\3\22\0035\5D\0005\6\24\0005\a\23\0=\a\25\0065\a\26\0=\a\27\0065\a\29\0005\b\28\0=\b\30\a5\b\31\0=\b \a=\a!\0066\a\14\0'\t\"\0B\a\2\0029\a#\a=\a$\0064\a\0\0=\a%\0066\a\14\0'\t\"\0B\a\2\0029\a&\a=\a'\0064\a\0\0=\a(\0065\a)\0=\a*\0064\a\0\0=\a+\0065\a,\0=\a-\0066\a\14\0'\t.\0B\a\2\0029\a/\a9\a0\a=\a1\0066\a\14\0'\t.\0B\a\2\0029\a2\a9\a0\a=\a3\0066\a\14\0'\t.\0B\a\2\0029\a4\a9\a0\a=\a5\0066\a\14\0'\t.\0B\a\2\0029\a6\a=\a6\0065\a?\0005\b8\0009\t7\0=\t9\b9\t\20\2=\t:\b9\t;\0=\t<\b9\t=\0=\t>\b=\b@\a5\bA\0009\t7\0=\t9\b9\t\20\2=\t:\b=\bB\a=\aC\6=\6E\0055\6J\0005\aF\0005\bG\0=\bH\a4\b\0\0=\bI\a=\aK\0065\aM\0005\bL\0=\bN\a=\a\18\0065\aO\0=\aP\6=\6Q\5B\3\2\0016\3\14\0'\5\16\0B\3\2\0029\3\17\3'\5P\0B\3\2\0016\3\14\0'\5\16\0B\3\2\0029\3\17\3'\5K\0B\3\2\0012\0\0ÄK\0\1\0\15extensions\bfzf\1\0\4\nfuzzy\2\14case_mode\15smart_case\25override_file_sorter\2\28override_generic_sorter\2\14base_dirs\1\0\1\17hidden_files\2\1\5\0\0\14~/.mynvim\n~/org\16~/.dotfiles\16~/workspace\rfrecency\1\0\0\15workspaces\20ignore_patterns\1\2\0\0\f*.git/*\1\0\2\16show_scores\1\19show_unindexed\2\rdefaults\1\0\0\rmappings\6n\1\0\0\6i\1\0\0\n<C-k>\23cycle_history_prev\n<C-j>\23cycle_history_next\n<C-o>\n<esc>\1\0\0\nclose\27buffer_previewer_maker\21qflist_previewer\22vim_buffer_qflist\19grep_previewer\23vim_buffer_vimgrep\19file_previewer\bnew\19vim_buffer_cat\25telescope.previewers\fset_env\1\0\1\14COLORTERM\14truecolor\17path_display\16borderchars\1\t\0\0\b‚îÄ\b‚îÇ\b‚îÄ\b‚îÇ\b‚ï≠\b‚ïÆ\b‚ïØ\b‚ï∞\vborder\19generic_sorter\29get_generic_fuzzy_sorter\25file_ignore_patterns\16file_sorter\19get_fuzzy_file\22telescope.sorters\18layout_config\rvertical\1\0\1\vmirror\1\15horizontal\1\0\0\1\0\1\vmirror\1\fhistory\1\0\1\tpath2~/.local/share/nvim/telescope_history.sqlite3\22vimgrep_arguments\1\0\n\rwinblend\3\0\17initial_mode\vinsert\20layout_strategy\15horizontal\21sorting_strategy\15descending\23selection_strategy\nreset\17entry_prefix\a  \20selection_caret\t‚û§ \18prompt_prefix\tÔÑÅ \ruse_less\2\19color_devicons\2\1\b\0\0\arg\18--color=never\17--no-heading\20--with-filename\18--line-number\r--column\17--smart-case\nsetup\0\21fzf_multi_select\28telescope.actions.state\fproject\19load_extension\14telescope\22telescope.actions\frequire\21packadd sql.nvim\rsql.nvim#packadd telescope-project.nvim\27telescope-project.nvim$packadd telescope-frecency.nvim\28telescope-frecency.nvim\25packadd plenary.nvim\17plenary.nvim\23packadd popup.nvim\bcmd\bvim\vloaded\15popup.nvim\19packer_plugins\0" },
    loaded = true,
    only_cond = false,
    only_config = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["tig-explorer.vim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/tig-explorer.vim",
    url = "https://github.com/iberianpig/tig-explorer.vim"
  },
  ["trouble.nvim"] = {
    config = { "\27LJ\2\nŒ\5\0\0\5\0\26\0\0296\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0005\4\5\0=\4\6\0035\4\a\0=\4\b\0035\4\t\0=\4\n\0035\4\v\0=\4\f\0035\4\r\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0035\4\19\0=\4\20\3=\3\21\0025\3\22\0=\3\23\0025\3\24\0=\3\25\2B\0\2\1K\0\1\0\nsigns\1\0\5\nerror\bÔÅó\16information\bÔÅ™\nother\bÔ´†\thint\bÔ†µ\fwarning\bÔÅ™\14auto_jump\1\2\0\0\20lsp_definitions\16action_keys\16toggle_fold\1\3\0\0\azA\aza\15open_folds\1\3\0\0\azR\azr\16close_folds\1\3\0\0\azM\azm\15jump_close\1\2\0\0\6o\ropen_tab\1\2\0\0\n<c-t>\16open_vsplit\1\2\0\0\n<c-v>\15open_split\1\2\0\0\n<c-x>\tjump\1\3\0\0\t<cr>\n<tab>\1\0\t\rprevious\6k\nclose\6q\tnext\6j\frefresh\6r\fpreview\6p\nhover\6K\19toggle_preview\6P\16toggle_mode\6m\vcancel\n<esc>\1\0\15\tmode\26workspace_diagnostics\25use_diagnostic_signs\1\fpadding\2\ngroup\2\16fold_closed\bÔë†\14fold_open\bÔëº\nicons\2\rposition\vbottom\vheight\3\n\nwidth\0032\14auto_fold\1\17auto_preview\2\15auto_close\1\14auto_open\1\17indent_lines\2\nsetup\ftrouble\frequire\0" },
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/trouble.nvim",
    url = "https://github.com/folke/trouble.nvim"
  },
  undotree = {
    commands = { "UndotreeToggle" },
    loaded = true,
    only_cond = false,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/undotree",
    url = "https://github.com/mbbill/undotree"
  },
  ["vim-airline"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vim-airline",
    url = "https://github.com/bling/vim-airline"
  },
  ["vim-easymotion"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vim-easymotion",
    url = "https://github.com/easymotion/vim-easymotion"
  },
  ["vim-emacscommandline"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vim-emacscommandline",
    url = "https://github.com/houtsnip/vim-emacscommandline"
  },
  ["vim-floaterm"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vim-floaterm",
    url = "https://github.com/voldikss/vim-floaterm"
  },
  ["vim-highlight-cursor-words"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vim-highlight-cursor-words",
    url = "https://github.com/pboettch/vim-highlight-cursor-words"
  },
  ["vim-repeat"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vim-repeat",
    url = "https://github.com/tpope/vim-repeat"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vim-surround",
    url = "https://github.com/tpope/vim-surround"
  },
  ["vim-trailing-whitespace"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vim-trailing-whitespace",
    url = "https://github.com/bronson/vim-trailing-whitespace"
  },
  ["vim-visual-multi"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vim-visual-multi",
    url = "https://github.com/mg979/vim-visual-multi"
  }
}

time([[Defining packer_plugins]], false)
-- Setup for: nerdcommenter
time([[Setup for nerdcommenter]], true)
try_loadstring("\27LJ\2\n∞\1\0\0\3\0\v\0\0156\0\0\0009\0\1\0)\1\0\0=\1\2\0006\0\0\0009\0\1\0005\1\5\0005\2\4\0=\2\6\0015\2\a\0=\2\b\0015\2\t\0=\2\n\1=\1\3\0K\0\1\0\nhjson\1\0\1\tleft\b// \njson5\1\0\1\tleft\b// \tjson\1\0\0\1\0\1\tleft\b// \25NERDCustomDelimiters\30NERDCreateDefaultMappings\6g\bvim\0", "setup", "nerdcommenter")
time([[Setup for nerdcommenter]], false)
time([[packadd for nerdcommenter]], true)
vim.cmd [[packadd nerdcommenter]]
time([[packadd for nerdcommenter]], false)
-- Setup for: rainbow
time([[Setup for rainbow]], true)
try_loadstring("\27LJ\2\nQ\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0002            let g:rainbow_active = 1\n        \bcmd\bvim\0", "setup", "rainbow")
time([[Setup for rainbow]], false)
time([[packadd for rainbow]], true)
vim.cmd [[packadd rainbow]]
time([[packadd for rainbow]], false)
-- Config for: rainbow
time([[Config for rainbow]], true)
try_loadstring("\27LJ\2\n\v\0\0\1\0\0\0\1K\0\1\0\0", "config", "rainbow")
time([[Config for rainbow]], false)
-- Config for: nvim-spectre
time([[Config for nvim-spectre]], true)
try_loadstring("\27LJ\2\nô\1\0\0\3\0\t\0\0156\0\0\0009\0\1\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\5\0B\0\2\0016\0\6\0'\2\a\0B\0\2\0029\0\b\0B\0\1\1K\0\1\0\nsetup\fspectre\frequire\25packadd plenary.nvim\bcmd\bvim\vloaded\17plenary.nvim\19packer_plugins\0", "config", "nvim-spectre")
time([[Config for nvim-spectre]], false)
-- Config for: indent-blankline
time([[Config for indent-blankline]], true)
try_loadstring("\27LJ\2\næ\3\0\0\3\0\f\0\0236\0\0\0009\0\1\0005\1\3\0=\1\2\0006\0\0\0009\0\1\0005\1\5\0=\1\4\0006\0\0\0009\0\1\0)\1\4\0=\1\6\0006\0\0\0009\0\1\0+\1\1\0=\1\a\0006\0\b\0'\2\t\0B\0\2\0029\0\n\0005\2\v\0B\0\2\1K\0\1\0\1\0\2\25show_current_context\2\25space_char_blankline\6 \nsetup\21indent_blankline\frequire$indent_blankline_use_treesitter\"indent_blankline_indent_level\1\14\0\0\15translator\22dapui_breakpoints\18dapui_watches\17dapui_stacks\17dapui_scopes\5\thelp\vpacker\rstartify\14dashboard\fvimwiki\rmarkdown\rcalendar&indent_blankline_filetype_exclude\1\2\0\0\b‚îÇ\31indent_blankline_char_list\6g\bvim\0", "config", "indent-blankline")
time([[Config for indent-blankline]], false)
-- Config for: asynctasks
time([[Config for asynctasks]], true)
try_loadstring("\27LJ\2\nˆ\1\0\0\4\0\f\0\0286\0\0\0009\0\1\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\5\0B\0\2\0016\0\3\0009\0\6\0004\1\3\0006\2\3\0009\2\6\0029\2\b\2'\3\t\0&\2\3\2>\2\1\1=\1\a\0006\0\3\0009\0\6\0)\1\b\0=\1\n\0006\0\3\0009\0\6\0)\1\1\0=\1\v\0K\0\1\0\18asyncrun_bell\18asyncrun_open\14tasks.ini\vCONFIG\28asynctasks_extra_config\6g\21packadd asyncrun\bcmd\bvim\vloaded\rasyncrun\19packer_plugins\0", "config", "asynctasks")
time([[Config for asynctasks]], false)
-- Config for: telescope.nvim
time([[Config for telescope.nvim]], true)
try_loadstring("\27LJ\2\n”\1\0\1\a\2\a\0\26-\1\0\0009\1\0\1\18\3\0\0B\1\2\0026\2\1\0009\2\2\2\18\6\1\0009\4\3\1B\4\2\0A\2\0\2)\3\1\0\1\3\2\0X\3\bÄ-\3\1\0009\3\4\3\18\5\0\0B\3\2\1-\3\1\0009\3\5\3B\3\1\1X\3\4Ä-\3\1\0009\3\6\3\18\5\0\0B\3\2\1K\0\1\0\1¿\0¿\14file_edit\16open_qflist\28send_selected_to_qflist\24get_multi_selection\tgetn\ntable\23get_current_picker◊\16\1\0\n\0R\0ß\0016\0\0\0009\0\1\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\5\0B\0\2\0016\0\0\0009\0\6\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\a\0B\0\2\0016\0\0\0009\0\b\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\t\0B\0\2\0016\0\0\0009\0\n\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\v\0B\0\2\0016\0\0\0009\0\f\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\r\0B\0\2\0016\0\14\0'\2\15\0B\0\2\0026\1\14\0'\3\16\0B\1\2\0029\1\17\1'\3\18\0B\1\2\0016\1\14\0'\3\19\0B\1\2\0024\2\0\0003\3\21\0=\3\20\0026\3\14\0'\5\16\0B\3\2\0029\3\22\0035\5D\0005\6\24\0005\a\23\0=\a\25\0065\a\26\0=\a\27\0065\a\29\0005\b\28\0=\b\30\a5\b\31\0=\b \a=\a!\0066\a\14\0'\t\"\0B\a\2\0029\a#\a=\a$\0064\a\0\0=\a%\0066\a\14\0'\t\"\0B\a\2\0029\a&\a=\a'\0064\a\0\0=\a(\0065\a)\0=\a*\0064\a\0\0=\a+\0065\a,\0=\a-\0066\a\14\0'\t.\0B\a\2\0029\a/\a9\a0\a=\a1\0066\a\14\0'\t.\0B\a\2\0029\a2\a9\a0\a=\a3\0066\a\14\0'\t.\0B\a\2\0029\a4\a9\a0\a=\a5\0066\a\14\0'\t.\0B\a\2\0029\a6\a=\a6\0065\a?\0005\b8\0009\t7\0=\t9\b9\t\20\2=\t:\b9\t;\0=\t<\b9\t=\0=\t>\b=\b@\a5\bA\0009\t7\0=\t9\b9\t\20\2=\t:\b=\bB\a=\aC\6=\6E\0055\6J\0005\aF\0005\bG\0=\bH\a4\b\0\0=\bI\a=\aK\0065\aM\0005\bL\0=\bN\a=\a\18\0065\aO\0=\aP\6=\6Q\5B\3\2\0016\3\14\0'\5\16\0B\3\2\0029\3\17\3'\5P\0B\3\2\0016\3\14\0'\5\16\0B\3\2\0029\3\17\3'\5K\0B\3\2\0012\0\0ÄK\0\1\0\15extensions\bfzf\1\0\4\nfuzzy\2\14case_mode\15smart_case\25override_file_sorter\2\28override_generic_sorter\2\14base_dirs\1\0\1\17hidden_files\2\1\5\0\0\14~/.mynvim\n~/org\16~/.dotfiles\16~/workspace\rfrecency\1\0\0\15workspaces\20ignore_patterns\1\2\0\0\f*.git/*\1\0\2\16show_scores\1\19show_unindexed\2\rdefaults\1\0\0\rmappings\6n\1\0\0\6i\1\0\0\n<C-k>\23cycle_history_prev\n<C-j>\23cycle_history_next\n<C-o>\n<esc>\1\0\0\nclose\27buffer_previewer_maker\21qflist_previewer\22vim_buffer_qflist\19grep_previewer\23vim_buffer_vimgrep\19file_previewer\bnew\19vim_buffer_cat\25telescope.previewers\fset_env\1\0\1\14COLORTERM\14truecolor\17path_display\16borderchars\1\t\0\0\b‚îÄ\b‚îÇ\b‚îÄ\b‚îÇ\b‚ï≠\b‚ïÆ\b‚ïØ\b‚ï∞\vborder\19generic_sorter\29get_generic_fuzzy_sorter\25file_ignore_patterns\16file_sorter\19get_fuzzy_file\22telescope.sorters\18layout_config\rvertical\1\0\1\vmirror\1\15horizontal\1\0\0\1\0\1\vmirror\1\fhistory\1\0\1\tpath2~/.local/share/nvim/telescope_history.sqlite3\22vimgrep_arguments\1\0\n\rwinblend\3\0\17initial_mode\vinsert\20layout_strategy\15horizontal\21sorting_strategy\15descending\23selection_strategy\nreset\17entry_prefix\a  \20selection_caret\t‚û§ \18prompt_prefix\tÔÑÅ \ruse_less\2\19color_devicons\2\1\b\0\0\arg\18--color=never\17--no-heading\20--with-filename\18--line-number\r--column\17--smart-case\nsetup\0\21fzf_multi_select\28telescope.actions.state\fproject\19load_extension\14telescope\22telescope.actions\frequire\21packadd sql.nvim\rsql.nvim#packadd telescope-project.nvim\27telescope-project.nvim$packadd telescope-frecency.nvim\28telescope-frecency.nvim\25packadd plenary.nvim\17plenary.nvim\23packadd popup.nvim\bcmd\bvim\vloaded\15popup.nvim\19packer_plugins\0", "config", "telescope.nvim")
time([[Config for telescope.nvim]], false)
-- Config for: trouble.nvim
time([[Config for trouble.nvim]], true)
try_loadstring("\27LJ\2\nŒ\5\0\0\5\0\26\0\0296\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0005\4\5\0=\4\6\0035\4\a\0=\4\b\0035\4\t\0=\4\n\0035\4\v\0=\4\f\0035\4\r\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0035\4\19\0=\4\20\3=\3\21\0025\3\22\0=\3\23\0025\3\24\0=\3\25\2B\0\2\1K\0\1\0\nsigns\1\0\5\nerror\bÔÅó\16information\bÔÅ™\nother\bÔ´†\thint\bÔ†µ\fwarning\bÔÅ™\14auto_jump\1\2\0\0\20lsp_definitions\16action_keys\16toggle_fold\1\3\0\0\azA\aza\15open_folds\1\3\0\0\azR\azr\16close_folds\1\3\0\0\azM\azm\15jump_close\1\2\0\0\6o\ropen_tab\1\2\0\0\n<c-t>\16open_vsplit\1\2\0\0\n<c-v>\15open_split\1\2\0\0\n<c-x>\tjump\1\3\0\0\t<cr>\n<tab>\1\0\t\rprevious\6k\nclose\6q\tnext\6j\frefresh\6r\fpreview\6p\nhover\6K\19toggle_preview\6P\16toggle_mode\6m\vcancel\n<esc>\1\0\15\tmode\26workspace_diagnostics\25use_diagnostic_signs\1\fpadding\2\ngroup\2\16fold_closed\bÔë†\14fold_open\bÔëº\nicons\2\rposition\vbottom\vheight\3\n\nwidth\0032\14auto_fold\1\17auto_preview\2\15auto_close\1\14auto_open\1\17indent_lines\2\nsetup\ftrouble\frequire\0", "config", "trouble.nvim")
time([[Config for trouble.nvim]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd telescope-project.nvim ]]
vim.cmd [[ packadd telescope-frecency.nvim ]]
time([[Sequenced loading]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file UndotreeToggle lua require("packer.load")({'undotree'}, { cmd = "UndotreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file AsyncTask lua require("packer.load")({'asynctasks'}, { cmd = "AsyncTask", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au VimEnter * ++once lua require("packer.load")({'telescope.nvim'}, { event = "VimEnter *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end

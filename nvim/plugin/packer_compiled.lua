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
  ["LeaderF-filer"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/LeaderF-filer",
    url = "https://github.com/tamago324/LeaderF-filer"
  },
  ["LeaderF-floaterm"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/LeaderF-floaterm",
    url = "https://github.com/voldikss/LeaderF-floaterm"
  },
  Rename2 = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/Rename2",
    url = "https://github.com/vim-scripts/Rename2"
  },
  Unimpaired = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/Unimpaired",
    url = "https://github.com/tpope/vim-unimpaired"
  },
  ["ack.vim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/ack.vim",
    url = "https://github.com/mileszs/ack.vim"
  },
  ["any-jump"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/any-jump",
    url = "https://github.com/pechorin/any-jump.vim"
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
  ["bufferline.nvim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/bufferline.nvim",
    url = "https://github.com/akinsho/bufferline.nvim"
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
  ["diffview.nvim"] = {
    commands = { "DiffviewOpen" },
    config = { "\27LJ\2\n≠\16\0\0\t\0[\0Ä\0026\0\0\0009\0\1\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\5\0B\0\2\0016\0\6\0'\2\a\0B\0\2\0029\0\b\0006\1\6\0'\3\t\0B\1\2\0029\1\n\0015\3\v\0005\4\f\0=\4\r\0035\4\14\0=\4\15\0035\4\16\0005\5\17\0=\5\18\0045\5\19\0=\5\20\4=\4\21\0035\4\23\0005\5\22\0=\5\24\0045\5\25\0=\5\20\4=\4\26\0035\4\27\0004\5\0\0=\5\28\0044\5\0\0=\5\29\4=\4\30\0034\4\0\0=\4\31\0035\4 \0005\5\"\0\18\6\0\0'\b!\0B\6\2\2=\6#\5\18\6\0\0'\b$\0B\6\2\2=\6%\5\18\6\0\0'\b&\0B\6\2\2=\6'\5\18\6\0\0'\b(\0B\6\2\2=\6)\5\18\6\0\0'\b*\0B\6\2\2=\6+\5\18\6\0\0'\b,\0B\6\2\2=\6-\5\18\6\0\0'\b.\0B\6\2\2=\6/\5=\0050\0045\0052\0\18\6\0\0'\b1\0B\6\2\2=\0063\5\18\6\0\0'\b1\0B\6\2\2=\0064\5\18\6\0\0'\b5\0B\6\2\2=\0066\5\18\6\0\0'\b5\0B\6\2\2=\0067\5\18\6\0\0'\b8\0B\6\2\2=\0069\5\18\6\0\0'\b8\0B\6\2\2=\6:\5\18\6\0\0'\b8\0B\6\2\2=\6;\5\18\6\0\0'\b<\0B\6\2\2=\6=\5\18\6\0\0'\b>\0B\6\2\2=\6?\5\18\6\0\0'\b@\0B\6\2\2=\6A\5\18\6\0\0'\bB\0B\6\2\2=\6C\5\18\6\0\0'\bD\0B\6\2\2=\6E\5\18\6\0\0'\b!\0B\6\2\2=\6#\5\18\6\0\0'\b$\0B\6\2\2=\6%\5\18\6\0\0'\b&\0B\6\2\2=\6'\5\18\6\0\0'\b(\0B\6\2\2=\6)\5\18\6\0\0'\b*\0B\6\2\2=\6+\5\18\6\0\0'\bF\0B\6\2\2=\6G\5\18\6\0\0'\bH\0B\6\2\2=\6I\5\18\6\0\0'\b,\0B\6\2\2=\6-\5\18\6\0\0'\b.\0B\6\2\2=\6/\5=\5\21\0045\5K\0\18\6\0\0'\bJ\0B\6\2\2=\6L\5\18\6\0\0'\bM\0B\6\2\2=\6N\5\18\6\0\0'\bO\0B\6\2\2=\6P\5\18\6\0\0'\bQ\0B\6\2\2=\6R\5\18\6\0\0'\bS\0B\6\2\2=\6T\5\18\6\0\0'\b1\0B\6\2\2=\0063\5\18\6\0\0'\b1\0B\6\2\2=\0064\5\18\6\0\0'\b5\0B\6\2\2=\0066\5\18\6\0\0'\b5\0B\6\2\2=\0067\5\18\6\0\0'\b8\0B\6\2\2=\0069\5\18\6\0\0'\b8\0B\6\2\2=\6:\5\18\6\0\0'\b8\0B\6\2\2=\6;\5\18\6\0\0'\b!\0B\6\2\2=\6#\5\18\6\0\0'\b$\0B\6\2\2=\6%\5\18\6\0\0'\b&\0B\6\2\2=\6'\5\18\6\0\0'\b(\0B\6\2\2=\6)\5\18\6\0\0'\b*\0B\6\2\2=\6+\5\18\6\0\0'\b,\0B\6\2\2=\6-\5\18\6\0\0'\b.\0B\6\2\2=\6/\5=\5\26\0045\5V\0\18\6\0\0'\bU\0B\6\2\2=\6#\5\18\6\0\0'\bW\0B\6\2\2=\6X\5=\5Y\4=\4Z\3B\1\2\0016\1\6\0'\3\t\0B\1\2\0029\1\n\0014\3\0\0B\1\2\1K\0\1\0\17key_bindings\17option_panel\6q\nclose\1\0\0\vselect\azM\20close_all_folds\azR\19open_all_folds\6y\14copy_hash\f<C-A-d>\21open_in_diffview\ag!\1\0\0\foptions\6f\24toggle_flatten_dirs\6i\18listing_style\6R\18refresh_files\6X\18restore_entry\6U\16unstage_all\6S\14stage_all\6-\23toggle_stage_entry\18<2-LeftMouse>\6o\t<cr>\17select_entry\t<up>\6k\15prev_entry\v<down>\6j\1\0\0\15next_entry\tview\14<leader>b\17toggle_files\14<leader>e\16focus_files\f<C-w>gf\18goto_file_tab\15<C-w><C-f>\20goto_file_split\agf\14goto_file\f<s-tab>\22select_prev_entry\n<tab>\1\0\0\22select_next_entry\1\0\1\21disable_defaults\1\nhooks\17default_args\24DiffviewFileHistory\17DiffviewOpen\1\0\0\23file_history_panel\1\0\2\rposition\vbottom\vheight\3\16\16log_options\1\0\0\1\0\6\vmerges\1\vfollow\1\14max_count\3Ä\2\ball\1\freverse\1\14no_merges\1\15file_panel\15win_config\1\0\2\rposition\tleft\nwidth\3#\17tree_options\1\0\2\17flatten_dirs\2\20folder_statuses\16only_folded\1\0\1\18listing_style\ttree\nsigns\1\0\2\16fold_closed\bÔë†\14fold_open\bÔëº\nicons\1\0\2\16folder_open\bÓóæ\18folder_closed\bÓóø\1\0\3\14use_icons\2\21enhanced_diff_hl\2\18diff_binaries\1\nsetup\rdiffview\22diffview_callback\20diffview.config\frequire\25packadd plenary.nvim\bcmd\bvim\vloaded\17plenary.nvim\19packer_plugins\0" },
    load_after = {},
    loaded = true,
    only_cond = false,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/diffview.nvim",
    url = "https://github.com/sindrets/diffview.nvim"
  },
  ["expand-region"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/expand-region",
    url = "https://github.com/terryma/vim-expand-region"
  },
  ["far.vim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/far.vim",
    url = "https://github.com/brooth/far.vim"
  },
  fzf = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/fzf",
    url = "https://github.com/junegunn/fzf"
  },
  ["fzf.vim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/fzf.vim",
    url = "https://github.com/junegunn/fzf.vim"
  },
  genutils = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/genutils",
    url = "https://github.com/vim-scripts/genutils"
  },
  ["goto-preview"] = {
    config = { "\27LJ\2\n>\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\17goto-preview\frequire\0" },
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/goto-preview",
    url = "https://github.com/rmagatti/goto-preview"
  },
  gutentags_plus = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/gutentags_plus",
    url = "https://github.com/xvhfeng/gutentags_plus"
  },
  ["hop.nvim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/hop.nvim",
    url = "https://github.com/phaazon/hop.nvim"
  },
  indentLine = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/indentLine",
    url = "https://github.com/Yggdroot/indentLine"
  },
  ["marks.nvim"] = {
    config = { "\27LJ\2\n∆\2\0\0\4\0\f\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0=\3\a\0024\3\0\0=\3\b\0025\3\t\0=\3\n\0024\3\0\0=\3\v\2B\0\2\1K\0\1\0\rmappings\15bookmark_0\1\0\3\tsign\b‚öë\14virt_text\16hello world\rannotate\1\23excluded_filetypes\18sign_priority\1\0\4\nlower\3\n\rbookmark\3\20\fbuiltin\3\b\nupper\3\15\18builtin_marks\1\5\0\0\6.\6<\6>\6^\1\0\4\21refresh_interval\3˙\1\22force_write_shada\1\vcyclic\2\21default_mappings\2\nsetup\nmarks\frequire\0" },
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/marks.nvim",
    url = "https://github.com/chentoast/marks.nvim"
  },
  material = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/material",
    url = "https://github.com/marko-cerovac/material.nvim"
  },
  ["mind.nvim"] = {
    config = { "\27LJ\2\n2\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\tmind\frequire\0" },
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/mind.nvim",
    url = "https://github.com/phaazon/mind.nvim"
  },
  ["neoterm.nvim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/neoterm.nvim",
    url = "https://github.com/xvhfeng/neoterm.nvim"
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
  ["nvim-spectre"] = {
    config = { "\27LJ\2\nô\1\0\0\3\0\t\0\0156\0\0\0009\0\1\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\5\0B\0\2\0016\0\6\0'\2\a\0B\0\2\0029\0\b\0B\0\1\1K\0\1\0\nsetup\fspectre\frequire\25packadd plenary.nvim\bcmd\bvim\vloaded\17plenary.nvim\19packer_plugins\0" },
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/nvim-spectre",
    url = "https://github.com/windwp/nvim-spectre"
  },
  ["nvim-tree.lua"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/nvim-tree.lua",
    url = "https://github.com/nvim-tree/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/nvim-tree/nvim-web-devicons"
  },
  orgmode = {
    config = { "\27LJ\2\nÚ\2\0\0\5\0\15\0\0266\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0016\0\0\0'\2\3\0B\0\2\0029\0\4\0005\2\b\0005\3\5\0005\4\6\0=\4\a\3=\3\t\0025\3\n\0=\3\v\2B\0\2\0016\0\0\0'\2\1\0B\0\2\0029\0\4\0005\2\r\0005\3\f\0=\3\14\2B\0\2\1K\0\1\0\21org_agenda_files\1\0\1\27org_default_notes_file\27~/notes/org/refile.org\1\3\0\0\18~/notes/org/*\25~/notes/my-orgs/**/*\21ensure_installed\1\2\0\0\borg\14highlight\1\0\0&additional_vim_regex_highlighting\1\2\0\0\borg\1\0\1\venable\2\nsetup\28nvim-treesitter.configs\21setup_ts_grammar\forgmode\frequire\0" },
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/orgmode",
    url = "https://github.com/nvim-orgmode/orgmode"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["qf-helper"] = {
    config = { "\27LJ\2\n«\2\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\floclist\1\0\6\19track_location\vcursor\15min_height\3\1\15max_height\3\n\20default_options\2\21default_bindings\2\14autoclose\2\rquickfix\1\0\6\19track_location\vcursor\15min_height\3\1\15max_height\3\n\20default_options\2\21default_bindings\2\14autoclose\2\1\0\2\19prefer_loclist\2\25sort_lsp_diagnostics\2\nsetup\14qf_helper\frequire\0" },
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/qf-helper",
    url = "https://github.com/stevearc/qf_helper.nvim"
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
  rnvimr = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/rnvimr",
    url = "https://github.com/kevinhwang91/rnvimr"
  },
  tagbar = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/tagbar",
    url = "https://github.com/preservim/tagbar"
  },
  ["telekasten.nvim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/telekasten.nvim",
    url = "https://github.com/renerocksai/telekasten.nvim"
  },
  ["testobj-word-column"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/testobj-word-column",
    url = "https://github.com/coderifous/textobj-word-column.vim"
  },
  ["tig-explorer.vim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/tig-explorer.vim",
    url = "https://github.com/iberianpig/tig-explorer.vim"
  },
  ["trouble.nvim"] = {
    config = { "\27LJ\2\n÷\5\0\0\5\0\26\0\0296\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0005\4\5\0=\4\6\0035\4\a\0=\4\b\0035\4\t\0=\4\n\0035\4\v\0=\4\f\0035\4\r\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0035\4\19\0=\4\20\3=\3\21\0025\3\22\0=\3\23\0025\3\24\0=\3\25\2B\0\2\1K\0\1\0\nsigns\1\0\5\16information\bÔÅ™\fwarning\bÔÅ™\thint\bÔ†µ\nother\bÔ´†\nerror\bÔÅó\14auto_jump\1\2\0\0\20lsp_definitions\16action_keys\16toggle_fold\1\3\0\0\azA\aza\15open_folds\1\3\0\0\azR\azr\16close_folds\1\3\0\0\azM\azm\15jump_close\1\2\0\0\6o\ropen_tab\1\2\0\0\n<c-t>\16open_vsplit\1\2\0\0\n<c-v>\15open_split\1\2\0\0\n<c-x>\tjump\1\3\0\0\t<cr>\n<tab>\1\0\t\fpreview\6p\tnext\n<c-n>\nhover\6K\19toggle_preview\6P\16toggle_mode\6m\frefresh\6r\nclose\6q\vcancel\n<esc>\rprevious\n<c-p>\1\0\15\rposition\vbottom\nwidth\0032\16fold_closed\bÔë†\tmode\26workspace_diagnostics\14fold_open\bÔëº\17indent_lines\2\25use_diagnostic_signs\1\15auto_close\1\nicons\2\vheight\3\n\14auto_open\1\ngroup\2\14auto_fold\1\17auto_preview\2\fpadding\2\nsetup\ftrouble\frequire\0" },
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
  ["vifm.vim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vifm.vim",
    url = "https://github.com/vifm/vifm.vim"
  },
  ["vim-airline"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vim-airline",
    url = "https://github.com/bling/vim-airline"
  },
  ["vim-emacscommandline"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vim-emacscommandline",
    url = "https://github.com/houtsnip/vim-emacscommandline"
  },
  ["vim-gutentags"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vim-gutentags",
    url = "https://github.com/xvhfeng/vim-gutentags"
  },
  ["vim-highlight-cursor-words"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vim-highlight-cursor-words",
    url = "https://github.com/pboettch/vim-highlight-cursor-words"
  },
  ["vim-kickfix"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vim-kickfix",
    url = "https://github.com/fcpg/vim-kickfix"
  },
  ["vim-lastplace"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vim-lastplace",
    url = "https://github.com/farmergreg/vim-lastplace"
  },
  ["vim-preview"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vim-preview",
    url = "https://github.com/skywind3000/vim-preview"
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
  ["vim-templates"] = {
    config = { "\27LJ\2\n\v\0\0\1\0\0\0\1K\0\1\0\0" },
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vim-templates",
    url = "https://github.com/xvhfeng/vim-templates"
  },
  ["vim-visual-multi"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vim-visual-multi",
    url = "https://github.com/mg979/vim-visual-multi"
  },
  vimcdoc = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vimcdoc",
    url = "https://github.com/yianwillis/vimcdoc"
  },
  vimwiki = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vimwiki",
    url = "https://github.com/vimwiki/vimwiki"
  },
  vista = {
    commands = { "Vista" },
    loaded = true,
    only_cond = false,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vista",
    url = "https://github.com/liuchengxu/vista.vim"
  },
  ["which-key.nvim"] = {
    config = { "\27LJ\2\nﬂ\a\0\0\5\0/\00036\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\b\0005\3\3\0005\4\4\0=\4\5\0035\4\6\0=\4\a\3=\3\t\0025\3\n\0=\3\v\0025\3\f\0=\3\r\0025\3\14\0=\3\15\0025\3\16\0=\3\17\0025\3\18\0005\4\19\0=\4\20\0035\4\21\0=\4\22\3=\3\23\0025\3\25\0005\4\24\0=\4\26\0035\4\27\0=\4\28\3=\3\29\0025\3\30\0=\3\31\0025\3 \0=\3!\0025\3#\0005\4\"\0=\4$\0035\4%\0=\4&\3=\3'\0025\3(\0=\3)\0025\3*\0004\4\0\0=\4+\0035\4,\0=\4-\3=\3.\2B\0\2\1K\0\1\0\fdisable\14filetypes\1\2\0\0\20TelescopePrompt\rbuftypes\1\0\0\20triggers_nowait\1\2\0\0\r<leader>\23triggers_blacklist\6v\1\3\0\0\6j\6k\6i\1\0\0\1\3\0\0\6j\6k\rtriggers\1\2\0\0\r<leader>\vhidden\1\t\0\0\r<silent>\n<cmd>\n<Cmd>\t<CR>\tcall\blua\a^:\a^ \vlayout\nwidth\1\0\2\bmin\3\20\bmax\0032\vheight\1\0\2\fspacing\3\3\nalign\tleft\1\0\2\bmin\3\4\bmax\3\25\vwindow\fpadding\1\5\0\0\3\2\3\2\3\2\3\2\vmargin\1\5\0\0\3\1\3\0\3\1\3\0\1\0\3\rposition\vbottom\vborder\tnone\rwinblend\3\0\19popup_mappings\1\0\2\14scroll_up\n<c-p>\16scroll_down\n<c-n>\nicons\1\0\3\14separator\b‚ûú\15breadcrumb\a¬ª\ngroup\6+\15key_labels\1\0\t\t<CR>\bRET\t<cr>\bRET\f<Space>\bSPC\f<SPACE>\bSPC\n<tab>\bTAB\f<space>\bSPC\n<Tab>\bTAB\n<TAB>\bTAB\t<Cr>\bRET\14operators\1\0\1\agc\rComments\fplugins\1\0\3\14show_help\2\19ignore_missing\1\14show_keys\2\fpresets\1\0\a\bnav\2\6z\2\fwindows\2\17text_objects\2\fmotions\2\14operators\2\6g\2\rspelling\1\0\2\fenabled\1\16suggestions\3\20\1\0\2\nmarks\2\14registers\2\nsetup\14which-key\frequire\0" },
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/which-key.nvim",
    url = "https://github.com/folke/which-key.nvim"
  }
}

time([[Defining packer_plugins]], false)
-- Setup for: diffview.nvim
time([[Setup for diffview.nvim]], true)
try_loadstring("\27LJ\2\n\v\0\0\1\0\0\0\1K\0\1\0\0", "setup", "diffview.nvim")
time([[Setup for diffview.nvim]], false)
-- Setup for: which-key.nvim
time([[Setup for which-key.nvim]], true)
try_loadstring("\27LJ\2\n\v\0\0\1\0\0\0\1K\0\1\0\0", "setup", "which-key.nvim")
time([[Setup for which-key.nvim]], false)
time([[packadd for which-key.nvim]], true)
vim.cmd [[packadd which-key.nvim]]
time([[packadd for which-key.nvim]], false)
-- Setup for: rainbow
time([[Setup for rainbow]], true)
try_loadstring("\27LJ\2\nQ\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0002            let g:rainbow_active = 1\n        \bcmd\bvim\0", "setup", "rainbow")
time([[Setup for rainbow]], false)
time([[packadd for rainbow]], true)
vim.cmd [[packadd rainbow]]
time([[packadd for rainbow]], false)
-- Setup for: vista
time([[Setup for vista]], true)
try_loadstring("\27LJ\2\n¢\6\0\0\3\0\21\00016\0\0\0009\0\1\0005\1\3\0=\1\2\0006\0\0\0009\0\1\0'\1\5\0=\1\4\0006\0\0\0009\0\1\0005\1\a\0=\1\6\0006\0\0\0009\0\1\0005\1\t\0=\1\b\0006\0\0\0009\0\1\0)\1\0\0=\1\n\0006\0\0\0009\0\1\0)\1\1\0=\1\v\0006\0\0\0009\0\1\0'\1\r\0=\1\f\0006\0\0\0009\0\1\0)\1<\0=\1\14\0006\0\0\0009\0\1\0'\1\16\0=\1\15\0006\0\0\0009\0\1\0+\1\2\0=\1\17\0006\0\0\0009\0\1\0)\1\1\0=\1\18\0006\0\0\0009\0\19\0'\2\20\0B\0\2\1K\0\1\0Î\1            let g:vista#renderer#icons = { \"function\": \" Ôö¶ \", \"functions\": \" Ôö¶ \", \"variable\": \" Óò§ \", \"variables\": \" Óò§ \", \"maps\": \" ÔÉÅ \", \"members \": \" Óò§ \", \"classes\": \" ÔÉ® \", \"autocommand groups\": \" Ô©è \"}\n            \bcmd$vista_enable_markdown_extension\29vista_disable_statusline\r60vsplit\27vista_sidebar_open_cmd\24vista_sidebar_width\22vertical topright\27vista_sidebar_position!vista_update_on_text_changed\23vista_stay_on_open\1\0\1\fhaskell\21ctags -x -o - -c\20vista_ctags_cmd\1\0\2\bcpp\nctags\6c\nctags\24vista_executive_for\nctags\28vista_default_executive\1\3\0\0\15‚ï∞‚îÄ‚ñ∏ \15‚îú‚îÄ‚ñ∏ \22vista_icon_indent\6g\bvim\0", "setup", "vista")
time([[Setup for vista]], false)
-- Setup for: vim-templates
time([[Setup for vim-templates]], true)
try_loadstring("\27LJ\2\n\v\0\0\1\0\0\0\1K\0\1\0\0", "setup", "vim-templates")
time([[Setup for vim-templates]], false)
time([[packadd for vim-templates]], true)
vim.cmd [[packadd vim-templates]]
time([[packadd for vim-templates]], false)
-- Setup for: nerdcommenter
time([[Setup for nerdcommenter]], true)
try_loadstring("\27LJ\2\n∞\1\0\0\3\0\v\0\0156\0\0\0009\0\1\0)\1\0\0=\1\2\0006\0\0\0009\0\1\0005\1\5\0005\2\4\0=\2\6\0015\2\a\0=\2\b\0015\2\t\0=\2\n\1=\1\3\0K\0\1\0\nhjson\1\0\1\tleft\b// \njson5\1\0\1\tleft\b// \tjson\1\0\0\1\0\1\tleft\b// \25NERDCustomDelimiters\30NERDCreateDefaultMappings\6g\bvim\0", "setup", "nerdcommenter")
time([[Setup for nerdcommenter]], false)
time([[packadd for nerdcommenter]], true)
vim.cmd [[packadd nerdcommenter]]
time([[packadd for nerdcommenter]], false)
-- Config for: qf-helper
time([[Config for qf-helper]], true)
try_loadstring("\27LJ\2\n«\2\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\floclist\1\0\6\19track_location\vcursor\15min_height\3\1\15max_height\3\n\20default_options\2\21default_bindings\2\14autoclose\2\rquickfix\1\0\6\19track_location\vcursor\15min_height\3\1\15max_height\3\n\20default_options\2\21default_bindings\2\14autoclose\2\1\0\2\19prefer_loclist\2\25sort_lsp_diagnostics\2\nsetup\14qf_helper\frequire\0", "config", "qf-helper")
time([[Config for qf-helper]], false)
-- Config for: vim-templates
time([[Config for vim-templates]], true)
try_loadstring("\27LJ\2\n\v\0\0\1\0\0\0\1K\0\1\0\0", "config", "vim-templates")
time([[Config for vim-templates]], false)
-- Config for: goto-preview
time([[Config for goto-preview]], true)
try_loadstring("\27LJ\2\n>\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\17goto-preview\frequire\0", "config", "goto-preview")
time([[Config for goto-preview]], false)
-- Config for: rainbow
time([[Config for rainbow]], true)
try_loadstring("\27LJ\2\n\v\0\0\1\0\0\0\1K\0\1\0\0", "config", "rainbow")
time([[Config for rainbow]], false)
-- Config for: trouble.nvim
time([[Config for trouble.nvim]], true)
try_loadstring("\27LJ\2\n÷\5\0\0\5\0\26\0\0296\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0005\4\5\0=\4\6\0035\4\a\0=\4\b\0035\4\t\0=\4\n\0035\4\v\0=\4\f\0035\4\r\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0035\4\19\0=\4\20\3=\3\21\0025\3\22\0=\3\23\0025\3\24\0=\3\25\2B\0\2\1K\0\1\0\nsigns\1\0\5\16information\bÔÅ™\fwarning\bÔÅ™\thint\bÔ†µ\nother\bÔ´†\nerror\bÔÅó\14auto_jump\1\2\0\0\20lsp_definitions\16action_keys\16toggle_fold\1\3\0\0\azA\aza\15open_folds\1\3\0\0\azR\azr\16close_folds\1\3\0\0\azM\azm\15jump_close\1\2\0\0\6o\ropen_tab\1\2\0\0\n<c-t>\16open_vsplit\1\2\0\0\n<c-v>\15open_split\1\2\0\0\n<c-x>\tjump\1\3\0\0\t<cr>\n<tab>\1\0\t\fpreview\6p\tnext\n<c-n>\nhover\6K\19toggle_preview\6P\16toggle_mode\6m\frefresh\6r\nclose\6q\vcancel\n<esc>\rprevious\n<c-p>\1\0\15\rposition\vbottom\nwidth\0032\16fold_closed\bÔë†\tmode\26workspace_diagnostics\14fold_open\bÔëº\17indent_lines\2\25use_diagnostic_signs\1\15auto_close\1\nicons\2\vheight\3\n\14auto_open\1\ngroup\2\14auto_fold\1\17auto_preview\2\fpadding\2\nsetup\ftrouble\frequire\0", "config", "trouble.nvim")
time([[Config for trouble.nvim]], false)
-- Config for: nvim-spectre
time([[Config for nvim-spectre]], true)
try_loadstring("\27LJ\2\nô\1\0\0\3\0\t\0\0156\0\0\0009\0\1\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\5\0B\0\2\0016\0\6\0'\2\a\0B\0\2\0029\0\b\0B\0\1\1K\0\1\0\nsetup\fspectre\frequire\25packadd plenary.nvim\bcmd\bvim\vloaded\17plenary.nvim\19packer_plugins\0", "config", "nvim-spectre")
time([[Config for nvim-spectre]], false)
-- Config for: which-key.nvim
time([[Config for which-key.nvim]], true)
try_loadstring("\27LJ\2\nﬂ\a\0\0\5\0/\00036\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\b\0005\3\3\0005\4\4\0=\4\5\0035\4\6\0=\4\a\3=\3\t\0025\3\n\0=\3\v\0025\3\f\0=\3\r\0025\3\14\0=\3\15\0025\3\16\0=\3\17\0025\3\18\0005\4\19\0=\4\20\0035\4\21\0=\4\22\3=\3\23\0025\3\25\0005\4\24\0=\4\26\0035\4\27\0=\4\28\3=\3\29\0025\3\30\0=\3\31\0025\3 \0=\3!\0025\3#\0005\4\"\0=\4$\0035\4%\0=\4&\3=\3'\0025\3(\0=\3)\0025\3*\0004\4\0\0=\4+\0035\4,\0=\4-\3=\3.\2B\0\2\1K\0\1\0\fdisable\14filetypes\1\2\0\0\20TelescopePrompt\rbuftypes\1\0\0\20triggers_nowait\1\2\0\0\r<leader>\23triggers_blacklist\6v\1\3\0\0\6j\6k\6i\1\0\0\1\3\0\0\6j\6k\rtriggers\1\2\0\0\r<leader>\vhidden\1\t\0\0\r<silent>\n<cmd>\n<Cmd>\t<CR>\tcall\blua\a^:\a^ \vlayout\nwidth\1\0\2\bmin\3\20\bmax\0032\vheight\1\0\2\fspacing\3\3\nalign\tleft\1\0\2\bmin\3\4\bmax\3\25\vwindow\fpadding\1\5\0\0\3\2\3\2\3\2\3\2\vmargin\1\5\0\0\3\1\3\0\3\1\3\0\1\0\3\rposition\vbottom\vborder\tnone\rwinblend\3\0\19popup_mappings\1\0\2\14scroll_up\n<c-p>\16scroll_down\n<c-n>\nicons\1\0\3\14separator\b‚ûú\15breadcrumb\a¬ª\ngroup\6+\15key_labels\1\0\t\t<CR>\bRET\t<cr>\bRET\f<Space>\bSPC\f<SPACE>\bSPC\n<tab>\bTAB\f<space>\bSPC\n<Tab>\bTAB\n<TAB>\bTAB\t<Cr>\bRET\14operators\1\0\1\agc\rComments\fplugins\1\0\3\14show_help\2\19ignore_missing\1\14show_keys\2\fpresets\1\0\a\bnav\2\6z\2\fwindows\2\17text_objects\2\fmotions\2\14operators\2\6g\2\rspelling\1\0\2\fenabled\1\16suggestions\3\20\1\0\2\nmarks\2\14registers\2\nsetup\14which-key\frequire\0", "config", "which-key.nvim")
time([[Config for which-key.nvim]], false)
-- Config for: diffview.nvim
time([[Config for diffview.nvim]], true)
try_loadstring("\27LJ\2\n≠\16\0\0\t\0[\0Ä\0026\0\0\0009\0\1\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\5\0B\0\2\0016\0\6\0'\2\a\0B\0\2\0029\0\b\0006\1\6\0'\3\t\0B\1\2\0029\1\n\0015\3\v\0005\4\f\0=\4\r\0035\4\14\0=\4\15\0035\4\16\0005\5\17\0=\5\18\0045\5\19\0=\5\20\4=\4\21\0035\4\23\0005\5\22\0=\5\24\0045\5\25\0=\5\20\4=\4\26\0035\4\27\0004\5\0\0=\5\28\0044\5\0\0=\5\29\4=\4\30\0034\4\0\0=\4\31\0035\4 \0005\5\"\0\18\6\0\0'\b!\0B\6\2\2=\6#\5\18\6\0\0'\b$\0B\6\2\2=\6%\5\18\6\0\0'\b&\0B\6\2\2=\6'\5\18\6\0\0'\b(\0B\6\2\2=\6)\5\18\6\0\0'\b*\0B\6\2\2=\6+\5\18\6\0\0'\b,\0B\6\2\2=\6-\5\18\6\0\0'\b.\0B\6\2\2=\6/\5=\0050\0045\0052\0\18\6\0\0'\b1\0B\6\2\2=\0063\5\18\6\0\0'\b1\0B\6\2\2=\0064\5\18\6\0\0'\b5\0B\6\2\2=\0066\5\18\6\0\0'\b5\0B\6\2\2=\0067\5\18\6\0\0'\b8\0B\6\2\2=\0069\5\18\6\0\0'\b8\0B\6\2\2=\6:\5\18\6\0\0'\b8\0B\6\2\2=\6;\5\18\6\0\0'\b<\0B\6\2\2=\6=\5\18\6\0\0'\b>\0B\6\2\2=\6?\5\18\6\0\0'\b@\0B\6\2\2=\6A\5\18\6\0\0'\bB\0B\6\2\2=\6C\5\18\6\0\0'\bD\0B\6\2\2=\6E\5\18\6\0\0'\b!\0B\6\2\2=\6#\5\18\6\0\0'\b$\0B\6\2\2=\6%\5\18\6\0\0'\b&\0B\6\2\2=\6'\5\18\6\0\0'\b(\0B\6\2\2=\6)\5\18\6\0\0'\b*\0B\6\2\2=\6+\5\18\6\0\0'\bF\0B\6\2\2=\6G\5\18\6\0\0'\bH\0B\6\2\2=\6I\5\18\6\0\0'\b,\0B\6\2\2=\6-\5\18\6\0\0'\b.\0B\6\2\2=\6/\5=\5\21\0045\5K\0\18\6\0\0'\bJ\0B\6\2\2=\6L\5\18\6\0\0'\bM\0B\6\2\2=\6N\5\18\6\0\0'\bO\0B\6\2\2=\6P\5\18\6\0\0'\bQ\0B\6\2\2=\6R\5\18\6\0\0'\bS\0B\6\2\2=\6T\5\18\6\0\0'\b1\0B\6\2\2=\0063\5\18\6\0\0'\b1\0B\6\2\2=\0064\5\18\6\0\0'\b5\0B\6\2\2=\0066\5\18\6\0\0'\b5\0B\6\2\2=\0067\5\18\6\0\0'\b8\0B\6\2\2=\0069\5\18\6\0\0'\b8\0B\6\2\2=\6:\5\18\6\0\0'\b8\0B\6\2\2=\6;\5\18\6\0\0'\b!\0B\6\2\2=\6#\5\18\6\0\0'\b$\0B\6\2\2=\6%\5\18\6\0\0'\b&\0B\6\2\2=\6'\5\18\6\0\0'\b(\0B\6\2\2=\6)\5\18\6\0\0'\b*\0B\6\2\2=\6+\5\18\6\0\0'\b,\0B\6\2\2=\6-\5\18\6\0\0'\b.\0B\6\2\2=\6/\5=\5\26\0045\5V\0\18\6\0\0'\bU\0B\6\2\2=\6#\5\18\6\0\0'\bW\0B\6\2\2=\6X\5=\5Y\4=\4Z\3B\1\2\0016\1\6\0'\3\t\0B\1\2\0029\1\n\0014\3\0\0B\1\2\1K\0\1\0\17key_bindings\17option_panel\6q\nclose\1\0\0\vselect\azM\20close_all_folds\azR\19open_all_folds\6y\14copy_hash\f<C-A-d>\21open_in_diffview\ag!\1\0\0\foptions\6f\24toggle_flatten_dirs\6i\18listing_style\6R\18refresh_files\6X\18restore_entry\6U\16unstage_all\6S\14stage_all\6-\23toggle_stage_entry\18<2-LeftMouse>\6o\t<cr>\17select_entry\t<up>\6k\15prev_entry\v<down>\6j\1\0\0\15next_entry\tview\14<leader>b\17toggle_files\14<leader>e\16focus_files\f<C-w>gf\18goto_file_tab\15<C-w><C-f>\20goto_file_split\agf\14goto_file\f<s-tab>\22select_prev_entry\n<tab>\1\0\0\22select_next_entry\1\0\1\21disable_defaults\1\nhooks\17default_args\24DiffviewFileHistory\17DiffviewOpen\1\0\0\23file_history_panel\1\0\2\rposition\vbottom\vheight\3\16\16log_options\1\0\0\1\0\6\vmerges\1\vfollow\1\14max_count\3Ä\2\ball\1\freverse\1\14no_merges\1\15file_panel\15win_config\1\0\2\rposition\tleft\nwidth\3#\17tree_options\1\0\2\17flatten_dirs\2\20folder_statuses\16only_folded\1\0\1\18listing_style\ttree\nsigns\1\0\2\16fold_closed\bÔë†\14fold_open\bÔëº\nicons\1\0\2\16folder_open\bÓóæ\18folder_closed\bÓóø\1\0\3\14use_icons\2\21enhanced_diff_hl\2\18diff_binaries\1\nsetup\rdiffview\22diffview_callback\20diffview.config\frequire\25packadd plenary.nvim\bcmd\bvim\vloaded\17plenary.nvim\19packer_plugins\0", "config", "diffview.nvim")
time([[Config for diffview.nvim]], false)
-- Config for: orgmode
time([[Config for orgmode]], true)
try_loadstring("\27LJ\2\nÚ\2\0\0\5\0\15\0\0266\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0016\0\0\0'\2\3\0B\0\2\0029\0\4\0005\2\b\0005\3\5\0005\4\6\0=\4\a\3=\3\t\0025\3\n\0=\3\v\2B\0\2\0016\0\0\0'\2\1\0B\0\2\0029\0\4\0005\2\r\0005\3\f\0=\3\14\2B\0\2\1K\0\1\0\21org_agenda_files\1\0\1\27org_default_notes_file\27~/notes/org/refile.org\1\3\0\0\18~/notes/org/*\25~/notes/my-orgs/**/*\21ensure_installed\1\2\0\0\borg\14highlight\1\0\0&additional_vim_regex_highlighting\1\2\0\0\borg\1\0\1\venable\2\nsetup\28nvim-treesitter.configs\21setup_ts_grammar\forgmode\frequire\0", "config", "orgmode")
time([[Config for orgmode]], false)
-- Config for: marks.nvim
time([[Config for marks.nvim]], true)
try_loadstring("\27LJ\2\n∆\2\0\0\4\0\f\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0=\3\a\0024\3\0\0=\3\b\0025\3\t\0=\3\n\0024\3\0\0=\3\v\2B\0\2\1K\0\1\0\rmappings\15bookmark_0\1\0\3\tsign\b‚öë\14virt_text\16hello world\rannotate\1\23excluded_filetypes\18sign_priority\1\0\4\nlower\3\n\rbookmark\3\20\fbuiltin\3\b\nupper\3\15\18builtin_marks\1\5\0\0\6.\6<\6>\6^\1\0\4\21refresh_interval\3˙\1\22force_write_shada\1\vcyclic\2\21default_mappings\2\nsetup\nmarks\frequire\0", "config", "marks.nvim")
time([[Config for marks.nvim]], false)
-- Config for: mind.nvim
time([[Config for mind.nvim]], true)
try_loadstring("\27LJ\2\n2\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\tmind\frequire\0", "config", "mind.nvim")
time([[Config for mind.nvim]], false)
-- Config for: asynctasks
time([[Config for asynctasks]], true)
try_loadstring("\27LJ\2\nˆ\1\0\0\4\0\f\0\0286\0\0\0009\0\1\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\5\0B\0\2\0016\0\3\0009\0\6\0004\1\3\0006\2\3\0009\2\6\0029\2\b\2'\3\t\0&\2\3\2>\2\1\1=\1\a\0006\0\3\0009\0\6\0)\1\b\0=\1\n\0006\0\3\0009\0\6\0)\1\1\0=\1\v\0K\0\1\0\18asyncrun_bell\18asyncrun_open\14tasks.ini\vCONFIG\28asynctasks_extra_config\6g\21packadd asyncrun\bcmd\bvim\vloaded\rasyncrun\19packer_plugins\0", "config", "asynctasks")
time([[Config for asynctasks]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd plenary.nvim ]]
time([[Sequenced loading]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewOpen lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewOpen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file AsyncTask lua require("packer.load")({'asynctasks'}, { cmd = "AsyncTask", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file UndotreeToggle lua require("packer.load")({'undotree'}, { cmd = "UndotreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Vista lua require("packer.load")({'vista'}, { cmd = "Vista", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
time([[Defining lazy-load commands]], false)


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

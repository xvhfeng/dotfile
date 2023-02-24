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
  ["LeaderF-marks"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/LeaderF-marks",
    url = "https://github.com/Yggdroot/LeaderF-marks"
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
  ale = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/ale",
    url = "https://github.com/dense-analysis/ale"
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
  ["deoplete.nvim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/deoplete.nvim",
    url = "https://github.com/Shougo/deoplete.nvim"
  },
  ["diffview.nvim"] = {
    commands = { "DiffviewLog", "DiffviewOpen", "DiffviewClose", "DiffviewRefresh", "DiffviewFocusFiles", "DiffviewFileHistory", "DiffviewToggleFiles" },
    config = { "\27LJ\2\nó\2\0\0\5\0\b\0\0176\0\0\0009\0\1\0'\2\2\0)\3$\0B\0\3\2'\1\3\0006\2\4\0009\2\5\2\18\3\0\0\18\4\1\0&\3\4\3=\3\6\0026\2\4\0009\2\5\2)\3\2\0=\3\a\2K\0\1\0\16showtabline\ftabline\bopt\bvim¶\1[x = prev conflict, ]x = next conflict, <leader>co = choose ours, <leader>ct = choose theirs, <leader>cb = choose base, <leader>ca = choose all, dx = choose none\6 \brep\vstringG\0\0\2\0\4\0\t6\0\0\0009\0\1\0+\1\0\0=\1\2\0006\0\0\0009\0\1\0)\1\0\0=\1\3\0K\0\1\0\16showtabline\ftabline\bopt\bvim’\1\1\0\6\0\16\0\0196\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\a\0005\4\5\0005\5\4\0=\5\6\4=\4\b\3=\3\t\0025\3\v\0003\4\n\0=\4\f\0033\4\r\0=\4\14\3=\3\15\2B\0\2\1K\0\1\0\nhooks\16view_closed\0\16view_opened\1\0\0\0\tview\15file_panel\1\0\0\15win_config\1\0\0\1\0\1\rposition\nright\1\0\1\21enhanced_diff_hl\2\nsetup\rdiffview\frequire\0" },
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
  ["lazygit.nvim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/lazygit.nvim",
    url = "https://github.com/kdheepak/lazygit.nvim"
  },
  ["lualine.nvim"] = {
    config = { "\27LJ\2\nÖ\1\0\0\6\0\b\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\4\0004\4\3\0005\5\3\0>\5\1\4=\4\5\3=\3\a\2B\0\2\1K\0\1\0\rsections\1\0\0\14lualine_a\1\0\0\1\2\1\0\rdatetime\nstyle\fdefault\nsetup\flualine\frequire\0" },
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  ["marks.nvim"] = {
    config = { "\27LJ\2\n∆\2\0\0\4\0\f\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0=\3\a\0024\3\0\0=\3\b\0025\3\t\0=\3\n\0024\3\0\0=\3\v\2B\0\2\1K\0\1\0\rmappings\15bookmark_0\1\0\3\tsign\b‚öë\14virt_text\16hello world\rannotate\1\23excluded_filetypes\18sign_priority\1\0\4\fbuiltin\3\b\nupper\3\15\nlower\3\n\rbookmark\3\20\18builtin_marks\1\5\0\0\6.\6<\6>\6^\1\0\4\21refresh_interval\3˙\1\22force_write_shada\1\vcyclic\2\21default_mappings\2\nsetup\nmarks\frequire\0" },
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
  ["neo-tree.nvim"] = {
    commands = { "NeoTreeFocusToggle" },
    loaded = true,
    only_cond = false,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/neo-tree.nvim",
    url = "https://github.com/nvim-neo-tree/neo-tree.nvim"
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
  ["nui.nvim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/nui.nvim",
    url = "https://github.com/MunifTanjim/nui.nvim"
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
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/kyazdani42/nvim-web-devicons"
  },
  ["nvim-window-picker"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/nvim-window-picker",
    url = "https://github.com/s1n7ax/nvim-window-picker"
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
  ["popup.nvim"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/popup.nvim",
    url = "https://github.com/nvim-lua/popup.nvim"
  },
  ["qf-helper"] = {
    config = { "\27LJ\2\n«\2\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\floclist\1\0\6\19track_location\vcursor\15min_height\3\1\15max_height\3\n\20default_options\2\21default_bindings\2\14autoclose\2\rquickfix\1\0\6\19track_location\vcursor\15min_height\3\1\15max_height\3\n\20default_options\2\21default_bindings\2\14autoclose\2\1\0\2\25sort_lsp_diagnostics\2\19prefer_loclist\2\nsetup\14qf_helper\frequire\0" },
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
  ["smart-splits.nvim"] = {
    config = { "\27LJ\2\n®\2\0\0\5\0\14\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\0025\3\b\0005\4\t\0=\4\n\0035\4\v\0=\4\f\3=\3\r\2B\0\2\1K\0\1\0\16resize_mode\nhooks\1\0\0\16resize_keys\1\5\0\0\n<c-h>\n<c-j>\n<c-k>\n<c-l>\1\0\2\rquit_key\n<ESC>\vsilent\1\21ignored_buftypes\1\3\0\0\rneo-tree\14nvim-tree\22ignored_filetypes\1\0\0\1\6\0\0\rneo-tree\14nvim-tree\vnofile\rquickfix\vprompt\nsetup\17smart-splits\frequire\0" },
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/smart-splits.nvim",
    url = "https://github.com/mrjones2014/smart-splits.nvim"
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
    after = { "telescope-frecency.nvim", "telescope-project.nvim" },
    config = { "\27LJ\2\n”\1\0\1\a\2\a\0\26-\1\0\0009\1\0\1\18\3\0\0B\1\2\0026\2\1\0009\2\2\2\18\6\1\0009\4\3\1B\4\2\0A\2\0\2)\3\1\0\1\3\2\0X\3\bÄ-\3\1\0009\3\4\3\18\5\0\0B\3\2\1-\3\1\0009\3\5\3B\3\1\1X\3\4Ä-\3\1\0009\3\6\3\18\5\0\0B\3\2\1K\0\1\0\1¿\0¿\14file_edit\16open_qflist\28send_selected_to_qflist\24get_multi_selection\tgetn\ntable\23get_current_picker√\16\1\0\n\0R\0ß\0016\0\0\0009\0\1\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\5\0B\0\2\0016\0\0\0009\0\6\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\a\0B\0\2\0016\0\0\0009\0\b\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\t\0B\0\2\0016\0\0\0009\0\n\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\v\0B\0\2\0016\0\0\0009\0\f\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\r\0B\0\2\0016\0\14\0'\2\15\0B\0\2\0026\1\14\0'\3\16\0B\1\2\0029\1\17\1'\3\18\0B\1\2\0016\1\14\0'\3\19\0B\1\2\0024\2\0\0003\3\21\0=\3\20\0026\3\14\0'\5\16\0B\3\2\0029\3\22\0035\5D\0005\6\24\0005\a\23\0=\a\25\0065\a\26\0=\a\27\0065\a\29\0005\b\28\0=\b\30\a5\b\31\0=\b \a=\a!\0066\a\14\0'\t\"\0B\a\2\0029\a#\a=\a$\0064\a\0\0=\a%\0066\a\14\0'\t\"\0B\a\2\0029\a&\a=\a'\0064\a\0\0=\a(\0065\a)\0=\a*\0064\a\0\0=\a+\0065\a,\0=\a-\0066\a\14\0'\t.\0B\a\2\0029\a/\a9\a0\a=\a1\0066\a\14\0'\t.\0B\a\2\0029\a2\a9\a0\a=\a3\0066\a\14\0'\t.\0B\a\2\0029\a4\a9\a0\a=\a5\0066\a\14\0'\t.\0B\a\2\0029\a6\a=\a6\0065\a?\0005\b8\0009\t7\0=\t9\b9\t\20\2=\t:\b9\t;\0=\t<\b9\t=\0=\t>\b=\b@\a5\bA\0009\t7\0=\t9\b9\t\20\2=\t:\b=\bB\a=\aC\6=\6E\0055\6J\0005\aF\0005\bG\0=\bH\a4\b\0\0=\bI\a=\aK\0065\aM\0005\bL\0=\bN\a=\a\18\0065\aO\0=\aP\6=\6Q\5B\3\2\0016\3\14\0'\5\16\0B\3\2\0029\3\17\3'\5P\0B\3\2\0016\3\14\0'\5\16\0B\3\2\0029\3\17\3'\5K\0B\3\2\0012\0\0ÄK\0\1\0\15extensions\bfzf\1\0\4\25override_file_sorter\2\28override_generic_sorter\2\nfuzzy\2\14case_mode\15smart_case\14base_dirs\1\0\1\17hidden_files\2\1\5\0\0\14~/.mynvim\n~/org\16~/.dotfiles\16~/workspace\rfrecency\1\0\0\15workspaces\20ignore_patterns\1\2\0\0\f*.git/*\1\0\2\19show_unindexed\2\16show_scores\1\rdefaults\1\0\0\rmappings\6n\1\0\0\6i\1\0\0\n<C-k>\23cycle_history_prev\n<C-j>\23cycle_history_next\n<C-o>\n<esc>\1\0\0\nclose\27buffer_previewer_maker\21qflist_previewer\22vim_buffer_qflist\19grep_previewer\23vim_buffer_vimgrep\19file_previewer\bnew\19vim_buffer_cat\25telescope.previewers\fset_env\1\0\1\14COLORTERM\14truecolor\17path_display\16borderchars\1\t\0\0\b‚îÄ\b‚îÇ\b‚îÄ\b‚îÇ\b‚ï≠\b‚ïÆ\b‚ïØ\b‚ï∞\vborder\19generic_sorter\29get_generic_fuzzy_sorter\25file_ignore_patterns\16file_sorter\19get_fuzzy_file\22telescope.sorters\18layout_config\rvertical\1\0\1\vmirror\1\15horizontal\1\0\0\1\0\1\vmirror\1\fhistory\1\0\1\tpath2~/.local/share/nvim/telescope_history.sqlite3\22vimgrep_arguments\1\0\t\ruse_less\2\19color_devicons\2\rwinblend\3\0\20layout_strategy\15horizontal\21sorting_strategy\15descending\23selection_strategy\nreset\17entry_prefix\a  \20selection_caret\t‚û§ \18prompt_prefix\tÔÑÅ \1\b\0\0\arg\18--color=never\17--no-heading\20--with-filename\18--line-number\r--column\17--smart-case\nsetup\0\21fzf_multi_select\28telescope.actions.state\fproject\19load_extension\14telescope\22telescope.actions\frequire\21packadd sql.nvim\rsql.nvim#packadd telescope-project.nvim\27telescope-project.nvim$packadd telescope-frecency.nvim\28telescope-frecency.nvim\25packadd plenary.nvim\17plenary.nvim\23packadd popup.nvim\bcmd\bvim\vloaded\15popup.nvim\19packer_plugins\0" },
    loaded = true,
    only_config = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
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
    config = { "\27LJ\2\n÷\5\0\0\5\0\26\0\0296\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0005\4\5\0=\4\6\0035\4\a\0=\4\b\0035\4\t\0=\4\n\0035\4\v\0=\4\f\0035\4\r\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0035\4\19\0=\4\20\3=\3\21\0025\3\22\0=\3\23\0025\3\24\0=\3\25\2B\0\2\1K\0\1\0\nsigns\1\0\5\fwarning\bÔÅ™\nerror\bÔÅó\nother\bÔ´†\16information\bÔÅ™\thint\bÔ†µ\14auto_jump\1\2\0\0\20lsp_definitions\16action_keys\16toggle_fold\1\3\0\0\azA\aza\15open_folds\1\3\0\0\azR\azr\16close_folds\1\3\0\0\azM\azm\15jump_close\1\2\0\0\6o\ropen_tab\1\2\0\0\n<c-t>\16open_vsplit\1\2\0\0\n<c-v>\15open_split\1\2\0\0\n<c-x>\tjump\1\3\0\0\t<cr>\n<tab>\1\0\t\tnext\n<c-n>\frefresh\6r\19toggle_preview\6P\16toggle_mode\6m\rprevious\n<c-p>\fpreview\6p\vcancel\n<esc>\nhover\6K\nclose\6q\1\0\15\nicons\2\vheight\3\n\25use_diagnostic_signs\1\fpadding\2\16fold_closed\bÔë†\rposition\vbottom\14auto_fold\1\17auto_preview\2\15auto_close\1\14auto_open\1\17indent_lines\2\14fold_open\bÔëº\nwidth\0032\ngroup\2\tmode\26workspace_diagnostics\nsetup\ftrouble\frequire\0" },
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
  ["vim-maximizer"] = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vim-maximizer",
    url = "https://github.com/szw/vim-maximizer"
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
  vimade = {
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/vimade",
    url = "https://github.com/TaDaa/vimade"
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
  ["which-key.nvim"] = {
    config = { "\27LJ\2\nﬂ\a\0\0\5\0/\00036\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\b\0005\3\3\0005\4\4\0=\4\5\0035\4\6\0=\4\a\3=\3\t\0025\3\n\0=\3\v\0025\3\f\0=\3\r\0025\3\14\0=\3\15\0025\3\16\0=\3\17\0025\3\18\0005\4\19\0=\4\20\0035\4\21\0=\4\22\3=\3\23\0025\3\25\0005\4\24\0=\4\26\0035\4\27\0=\4\28\3=\3\29\0025\3\30\0=\3\31\0025\3 \0=\3!\0025\3#\0005\4\"\0=\4$\0035\4%\0=\4&\3=\3'\0025\3(\0=\3)\0025\3*\0004\4\0\0=\4+\0035\4,\0=\4-\3=\3.\2B\0\2\1K\0\1\0\fdisable\14filetypes\1\2\0\0\20TelescopePrompt\rbuftypes\1\0\0\20triggers_nowait\1\2\0\0\r<leader>\23triggers_blacklist\6v\1\3\0\0\6j\6k\6i\1\0\0\1\3\0\0\6j\6k\rtriggers\1\2\0\0\r<leader>\vhidden\1\t\0\0\r<silent>\n<cmd>\n<Cmd>\t<CR>\tcall\blua\a^:\a^ \vlayout\nwidth\1\0\2\bmin\3\20\bmax\0032\vheight\1\0\2\fspacing\3\3\nalign\tleft\1\0\2\bmin\3\4\bmax\3\25\vwindow\fpadding\1\5\0\0\3\2\3\2\3\2\3\2\vmargin\1\5\0\0\3\1\3\0\3\1\3\0\1\0\3\rwinblend\3\0\vborder\tnone\rposition\vbottom\19popup_mappings\1\0\2\14scroll_up\n<c-p>\16scroll_down\n<c-n>\nicons\1\0\3\15breadcrumb\a¬ª\14separator\b‚ûú\ngroup\6+\15key_labels\1\0\t\n<Tab>\bTAB\n<TAB>\bTAB\t<CR>\bRET\t<Cr>\bRET\t<cr>\bRET\f<Space>\bSPC\f<SPACE>\bSPC\f<space>\bSPC\n<tab>\bTAB\14operators\1\0\1\agc\rComments\fplugins\1\0\3\14show_keys\2\14show_help\2\19ignore_missing\1\fpresets\1\0\a\fwindows\2\17text_objects\2\fmotions\2\14operators\2\6g\2\bnav\2\6z\2\rspelling\1\0\2\fenabled\1\16suggestions\3\20\1\0\2\14registers\2\nmarks\2\nsetup\14which-key\frequire\0" },
    loaded = true,
    path = "/Users/xuhaifeng/.local/share/nvim/site/pack/packer/start/which-key.nvim",
    url = "https://github.com/folke/which-key.nvim"
  }
}

time([[Defining packer_plugins]], false)
-- Setup for: vim-templates
time([[Setup for vim-templates]], true)
try_loadstring("\27LJ\2\n\v\0\0\1\0\0\0\1K\0\1\0\0", "setup", "vim-templates")
time([[Setup for vim-templates]], false)
time([[packadd for vim-templates]], true)
vim.cmd [[packadd vim-templates]]
time([[packadd for vim-templates]], false)
-- Setup for: vimade
time([[Setup for vimade]], true)
try_loadstring("\27LJ\2\n\v\0\0\1\0\0\0\1K\0\1\0\0", "setup", "vimade")
time([[Setup for vimade]], false)
time([[packadd for vimade]], true)
vim.cmd [[packadd vimade]]
time([[packadd for vimade]], false)
-- Setup for: rainbow
time([[Setup for rainbow]], true)
try_loadstring("\27LJ\2\nQ\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0002            let g:rainbow_active = 1\n        \bcmd\bvim\0", "setup", "rainbow")
time([[Setup for rainbow]], false)
time([[packadd for rainbow]], true)
vim.cmd [[packadd rainbow]]
time([[packadd for rainbow]], false)
-- Setup for: which-key.nvim
time([[Setup for which-key.nvim]], true)
try_loadstring("\27LJ\2\n\v\0\0\1\0\0\0\1K\0\1\0\0", "setup", "which-key.nvim")
time([[Setup for which-key.nvim]], false)
time([[packadd for which-key.nvim]], true)
vim.cmd [[packadd which-key.nvim]]
time([[packadd for which-key.nvim]], false)
-- Setup for: nerdcommenter
time([[Setup for nerdcommenter]], true)
try_loadstring("\27LJ\2\n∞\1\0\0\3\0\v\0\0156\0\0\0009\0\1\0)\1\0\0=\1\2\0006\0\0\0009\0\1\0005\1\5\0005\2\4\0=\2\6\0015\2\a\0=\2\b\0015\2\t\0=\2\n\1=\1\3\0K\0\1\0\nhjson\1\0\1\tleft\b// \njson5\1\0\1\tleft\b// \tjson\1\0\0\1\0\1\tleft\b// \25NERDCustomDelimiters\30NERDCreateDefaultMappings\6g\bvim\0", "setup", "nerdcommenter")
time([[Setup for nerdcommenter]], false)
time([[packadd for nerdcommenter]], true)
vim.cmd [[packadd nerdcommenter]]
time([[packadd for nerdcommenter]], false)
-- Config for: trouble.nvim
time([[Config for trouble.nvim]], true)
try_loadstring("\27LJ\2\n÷\5\0\0\5\0\26\0\0296\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0005\4\5\0=\4\6\0035\4\a\0=\4\b\0035\4\t\0=\4\n\0035\4\v\0=\4\f\0035\4\r\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0035\4\19\0=\4\20\3=\3\21\0025\3\22\0=\3\23\0025\3\24\0=\3\25\2B\0\2\1K\0\1\0\nsigns\1\0\5\fwarning\bÔÅ™\nerror\bÔÅó\nother\bÔ´†\16information\bÔÅ™\thint\bÔ†µ\14auto_jump\1\2\0\0\20lsp_definitions\16action_keys\16toggle_fold\1\3\0\0\azA\aza\15open_folds\1\3\0\0\azR\azr\16close_folds\1\3\0\0\azM\azm\15jump_close\1\2\0\0\6o\ropen_tab\1\2\0\0\n<c-t>\16open_vsplit\1\2\0\0\n<c-v>\15open_split\1\2\0\0\n<c-x>\tjump\1\3\0\0\t<cr>\n<tab>\1\0\t\tnext\n<c-n>\frefresh\6r\19toggle_preview\6P\16toggle_mode\6m\rprevious\n<c-p>\fpreview\6p\vcancel\n<esc>\nhover\6K\nclose\6q\1\0\15\nicons\2\vheight\3\n\25use_diagnostic_signs\1\fpadding\2\16fold_closed\bÔë†\rposition\vbottom\14auto_fold\1\17auto_preview\2\15auto_close\1\14auto_open\1\17indent_lines\2\14fold_open\bÔëº\nwidth\0032\ngroup\2\tmode\26workspace_diagnostics\nsetup\ftrouble\frequire\0", "config", "trouble.nvim")
time([[Config for trouble.nvim]], false)
-- Config for: diffview.nvim
time([[Config for diffview.nvim]], true)
try_loadstring("\27LJ\2\nó\2\0\0\5\0\b\0\0176\0\0\0009\0\1\0'\2\2\0)\3$\0B\0\3\2'\1\3\0006\2\4\0009\2\5\2\18\3\0\0\18\4\1\0&\3\4\3=\3\6\0026\2\4\0009\2\5\2)\3\2\0=\3\a\2K\0\1\0\16showtabline\ftabline\bopt\bvim¶\1[x = prev conflict, ]x = next conflict, <leader>co = choose ours, <leader>ct = choose theirs, <leader>cb = choose base, <leader>ca = choose all, dx = choose none\6 \brep\vstringG\0\0\2\0\4\0\t6\0\0\0009\0\1\0+\1\0\0=\1\2\0006\0\0\0009\0\1\0)\1\0\0=\1\3\0K\0\1\0\16showtabline\ftabline\bopt\bvim’\1\1\0\6\0\16\0\0196\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\a\0005\4\5\0005\5\4\0=\5\6\4=\4\b\3=\3\t\0025\3\v\0003\4\n\0=\4\f\0033\4\r\0=\4\14\3=\3\15\2B\0\2\1K\0\1\0\nhooks\16view_closed\0\16view_opened\1\0\0\0\tview\15file_panel\1\0\0\15win_config\1\0\0\1\0\1\rposition\nright\1\0\1\21enhanced_diff_hl\2\nsetup\rdiffview\frequire\0", "config", "diffview.nvim")
time([[Config for diffview.nvim]], false)
-- Config for: orgmode
time([[Config for orgmode]], true)
try_loadstring("\27LJ\2\nÚ\2\0\0\5\0\15\0\0266\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0016\0\0\0'\2\3\0B\0\2\0029\0\4\0005\2\b\0005\3\5\0005\4\6\0=\4\a\3=\3\t\0025\3\n\0=\3\v\2B\0\2\0016\0\0\0'\2\1\0B\0\2\0029\0\4\0005\2\r\0005\3\f\0=\3\14\2B\0\2\1K\0\1\0\21org_agenda_files\1\0\1\27org_default_notes_file\27~/notes/org/refile.org\1\3\0\0\18~/notes/org/*\25~/notes/my-orgs/**/*\21ensure_installed\1\2\0\0\borg\14highlight\1\0\0&additional_vim_regex_highlighting\1\2\0\0\borg\1\0\1\venable\2\nsetup\28nvim-treesitter.configs\21setup_ts_grammar\forgmode\frequire\0", "config", "orgmode")
time([[Config for orgmode]], false)
-- Config for: goto-preview
time([[Config for goto-preview]], true)
try_loadstring("\27LJ\2\n>\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\17goto-preview\frequire\0", "config", "goto-preview")
time([[Config for goto-preview]], false)
-- Config for: which-key.nvim
time([[Config for which-key.nvim]], true)
try_loadstring("\27LJ\2\nﬂ\a\0\0\5\0/\00036\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\b\0005\3\3\0005\4\4\0=\4\5\0035\4\6\0=\4\a\3=\3\t\0025\3\n\0=\3\v\0025\3\f\0=\3\r\0025\3\14\0=\3\15\0025\3\16\0=\3\17\0025\3\18\0005\4\19\0=\4\20\0035\4\21\0=\4\22\3=\3\23\0025\3\25\0005\4\24\0=\4\26\0035\4\27\0=\4\28\3=\3\29\0025\3\30\0=\3\31\0025\3 \0=\3!\0025\3#\0005\4\"\0=\4$\0035\4%\0=\4&\3=\3'\0025\3(\0=\3)\0025\3*\0004\4\0\0=\4+\0035\4,\0=\4-\3=\3.\2B\0\2\1K\0\1\0\fdisable\14filetypes\1\2\0\0\20TelescopePrompt\rbuftypes\1\0\0\20triggers_nowait\1\2\0\0\r<leader>\23triggers_blacklist\6v\1\3\0\0\6j\6k\6i\1\0\0\1\3\0\0\6j\6k\rtriggers\1\2\0\0\r<leader>\vhidden\1\t\0\0\r<silent>\n<cmd>\n<Cmd>\t<CR>\tcall\blua\a^:\a^ \vlayout\nwidth\1\0\2\bmin\3\20\bmax\0032\vheight\1\0\2\fspacing\3\3\nalign\tleft\1\0\2\bmin\3\4\bmax\3\25\vwindow\fpadding\1\5\0\0\3\2\3\2\3\2\3\2\vmargin\1\5\0\0\3\1\3\0\3\1\3\0\1\0\3\rwinblend\3\0\vborder\tnone\rposition\vbottom\19popup_mappings\1\0\2\14scroll_up\n<c-p>\16scroll_down\n<c-n>\nicons\1\0\3\15breadcrumb\a¬ª\14separator\b‚ûú\ngroup\6+\15key_labels\1\0\t\n<Tab>\bTAB\n<TAB>\bTAB\t<CR>\bRET\t<Cr>\bRET\t<cr>\bRET\f<Space>\bSPC\f<SPACE>\bSPC\f<space>\bSPC\n<tab>\bTAB\14operators\1\0\1\agc\rComments\fplugins\1\0\3\14show_keys\2\14show_help\2\19ignore_missing\1\fpresets\1\0\a\fwindows\2\17text_objects\2\fmotions\2\14operators\2\6g\2\bnav\2\6z\2\rspelling\1\0\2\fenabled\1\16suggestions\3\20\1\0\2\14registers\2\nmarks\2\nsetup\14which-key\frequire\0", "config", "which-key.nvim")
time([[Config for which-key.nvim]], false)
-- Config for: marks.nvim
time([[Config for marks.nvim]], true)
try_loadstring("\27LJ\2\n∆\2\0\0\4\0\f\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0=\3\a\0024\3\0\0=\3\b\0025\3\t\0=\3\n\0024\3\0\0=\3\v\2B\0\2\1K\0\1\0\rmappings\15bookmark_0\1\0\3\tsign\b‚öë\14virt_text\16hello world\rannotate\1\23excluded_filetypes\18sign_priority\1\0\4\fbuiltin\3\b\nupper\3\15\nlower\3\n\rbookmark\3\20\18builtin_marks\1\5\0\0\6.\6<\6>\6^\1\0\4\21refresh_interval\3˙\1\22force_write_shada\1\vcyclic\2\21default_mappings\2\nsetup\nmarks\frequire\0", "config", "marks.nvim")
time([[Config for marks.nvim]], false)
-- Config for: asynctasks
time([[Config for asynctasks]], true)
try_loadstring("\27LJ\2\nˆ\1\0\0\4\0\f\0\0286\0\0\0009\0\1\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\5\0B\0\2\0016\0\3\0009\0\6\0004\1\3\0006\2\3\0009\2\6\0029\2\b\2'\3\t\0&\2\3\2>\2\1\1=\1\a\0006\0\3\0009\0\6\0)\1\b\0=\1\n\0006\0\3\0009\0\6\0)\1\1\0=\1\v\0K\0\1\0\18asyncrun_bell\18asyncrun_open\14tasks.ini\vCONFIG\28asynctasks_extra_config\6g\21packadd asyncrun\bcmd\bvim\vloaded\rasyncrun\19packer_plugins\0", "config", "asynctasks")
time([[Config for asynctasks]], false)
-- Config for: mind.nvim
time([[Config for mind.nvim]], true)
try_loadstring("\27LJ\2\n2\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\tmind\frequire\0", "config", "mind.nvim")
time([[Config for mind.nvim]], false)
-- Config for: vim-templates
time([[Config for vim-templates]], true)
try_loadstring("\27LJ\2\n\v\0\0\1\0\0\0\1K\0\1\0\0", "config", "vim-templates")
time([[Config for vim-templates]], false)
-- Config for: smart-splits.nvim
time([[Config for smart-splits.nvim]], true)
try_loadstring("\27LJ\2\n®\2\0\0\5\0\14\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\0025\3\b\0005\4\t\0=\4\n\0035\4\v\0=\4\f\3=\3\r\2B\0\2\1K\0\1\0\16resize_mode\nhooks\1\0\0\16resize_keys\1\5\0\0\n<c-h>\n<c-j>\n<c-k>\n<c-l>\1\0\2\rquit_key\n<ESC>\vsilent\1\21ignored_buftypes\1\3\0\0\rneo-tree\14nvim-tree\22ignored_filetypes\1\0\0\1\6\0\0\rneo-tree\14nvim-tree\vnofile\rquickfix\vprompt\nsetup\17smart-splits\frequire\0", "config", "smart-splits.nvim")
time([[Config for smart-splits.nvim]], false)
-- Config for: rainbow
time([[Config for rainbow]], true)
try_loadstring("\27LJ\2\n\v\0\0\1\0\0\0\1K\0\1\0\0", "config", "rainbow")
time([[Config for rainbow]], false)
-- Config for: nvim-spectre
time([[Config for nvim-spectre]], true)
try_loadstring("\27LJ\2\nô\1\0\0\3\0\t\0\0156\0\0\0009\0\1\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\5\0B\0\2\0016\0\6\0'\2\a\0B\0\2\0029\0\b\0B\0\1\1K\0\1\0\nsetup\fspectre\frequire\25packadd plenary.nvim\bcmd\bvim\vloaded\17plenary.nvim\19packer_plugins\0", "config", "nvim-spectre")
time([[Config for nvim-spectre]], false)
-- Config for: qf-helper
time([[Config for qf-helper]], true)
try_loadstring("\27LJ\2\n«\2\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\floclist\1\0\6\19track_location\vcursor\15min_height\3\1\15max_height\3\n\20default_options\2\21default_bindings\2\14autoclose\2\rquickfix\1\0\6\19track_location\vcursor\15min_height\3\1\15max_height\3\n\20default_options\2\21default_bindings\2\14autoclose\2\1\0\2\25sort_lsp_diagnostics\2\19prefer_loclist\2\nsetup\14qf_helper\frequire\0", "config", "qf-helper")
time([[Config for qf-helper]], false)
-- Config for: telescope.nvim
time([[Config for telescope.nvim]], true)
try_loadstring("\27LJ\2\n”\1\0\1\a\2\a\0\26-\1\0\0009\1\0\1\18\3\0\0B\1\2\0026\2\1\0009\2\2\2\18\6\1\0009\4\3\1B\4\2\0A\2\0\2)\3\1\0\1\3\2\0X\3\bÄ-\3\1\0009\3\4\3\18\5\0\0B\3\2\1-\3\1\0009\3\5\3B\3\1\1X\3\4Ä-\3\1\0009\3\6\3\18\5\0\0B\3\2\1K\0\1\0\1¿\0¿\14file_edit\16open_qflist\28send_selected_to_qflist\24get_multi_selection\tgetn\ntable\23get_current_picker√\16\1\0\n\0R\0ß\0016\0\0\0009\0\1\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\5\0B\0\2\0016\0\0\0009\0\6\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\a\0B\0\2\0016\0\0\0009\0\b\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\t\0B\0\2\0016\0\0\0009\0\n\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\v\0B\0\2\0016\0\0\0009\0\f\0009\0\2\0\14\0\0\0X\0\4Ä6\0\3\0009\0\4\0'\2\r\0B\0\2\0016\0\14\0'\2\15\0B\0\2\0026\1\14\0'\3\16\0B\1\2\0029\1\17\1'\3\18\0B\1\2\0016\1\14\0'\3\19\0B\1\2\0024\2\0\0003\3\21\0=\3\20\0026\3\14\0'\5\16\0B\3\2\0029\3\22\0035\5D\0005\6\24\0005\a\23\0=\a\25\0065\a\26\0=\a\27\0065\a\29\0005\b\28\0=\b\30\a5\b\31\0=\b \a=\a!\0066\a\14\0'\t\"\0B\a\2\0029\a#\a=\a$\0064\a\0\0=\a%\0066\a\14\0'\t\"\0B\a\2\0029\a&\a=\a'\0064\a\0\0=\a(\0065\a)\0=\a*\0064\a\0\0=\a+\0065\a,\0=\a-\0066\a\14\0'\t.\0B\a\2\0029\a/\a9\a0\a=\a1\0066\a\14\0'\t.\0B\a\2\0029\a2\a9\a0\a=\a3\0066\a\14\0'\t.\0B\a\2\0029\a4\a9\a0\a=\a5\0066\a\14\0'\t.\0B\a\2\0029\a6\a=\a6\0065\a?\0005\b8\0009\t7\0=\t9\b9\t\20\2=\t:\b9\t;\0=\t<\b9\t=\0=\t>\b=\b@\a5\bA\0009\t7\0=\t9\b9\t\20\2=\t:\b=\bB\a=\aC\6=\6E\0055\6J\0005\aF\0005\bG\0=\bH\a4\b\0\0=\bI\a=\aK\0065\aM\0005\bL\0=\bN\a=\a\18\0065\aO\0=\aP\6=\6Q\5B\3\2\0016\3\14\0'\5\16\0B\3\2\0029\3\17\3'\5P\0B\3\2\0016\3\14\0'\5\16\0B\3\2\0029\3\17\3'\5K\0B\3\2\0012\0\0ÄK\0\1\0\15extensions\bfzf\1\0\4\25override_file_sorter\2\28override_generic_sorter\2\nfuzzy\2\14case_mode\15smart_case\14base_dirs\1\0\1\17hidden_files\2\1\5\0\0\14~/.mynvim\n~/org\16~/.dotfiles\16~/workspace\rfrecency\1\0\0\15workspaces\20ignore_patterns\1\2\0\0\f*.git/*\1\0\2\19show_unindexed\2\16show_scores\1\rdefaults\1\0\0\rmappings\6n\1\0\0\6i\1\0\0\n<C-k>\23cycle_history_prev\n<C-j>\23cycle_history_next\n<C-o>\n<esc>\1\0\0\nclose\27buffer_previewer_maker\21qflist_previewer\22vim_buffer_qflist\19grep_previewer\23vim_buffer_vimgrep\19file_previewer\bnew\19vim_buffer_cat\25telescope.previewers\fset_env\1\0\1\14COLORTERM\14truecolor\17path_display\16borderchars\1\t\0\0\b‚îÄ\b‚îÇ\b‚îÄ\b‚îÇ\b‚ï≠\b‚ïÆ\b‚ïØ\b‚ï∞\vborder\19generic_sorter\29get_generic_fuzzy_sorter\25file_ignore_patterns\16file_sorter\19get_fuzzy_file\22telescope.sorters\18layout_config\rvertical\1\0\1\vmirror\1\15horizontal\1\0\0\1\0\1\vmirror\1\fhistory\1\0\1\tpath2~/.local/share/nvim/telescope_history.sqlite3\22vimgrep_arguments\1\0\t\ruse_less\2\19color_devicons\2\rwinblend\3\0\20layout_strategy\15horizontal\21sorting_strategy\15descending\23selection_strategy\nreset\17entry_prefix\a  \20selection_caret\t‚û§ \18prompt_prefix\tÔÑÅ \1\b\0\0\arg\18--color=never\17--no-heading\20--with-filename\18--line-number\r--column\17--smart-case\nsetup\0\21fzf_multi_select\28telescope.actions.state\fproject\19load_extension\14telescope\22telescope.actions\frequire\21packadd sql.nvim\rsql.nvim#packadd telescope-project.nvim\27telescope-project.nvim$packadd telescope-frecency.nvim\28telescope-frecency.nvim\25packadd plenary.nvim\17plenary.nvim\23packadd popup.nvim\bcmd\bvim\vloaded\15popup.nvim\19packer_plugins\0", "config", "telescope.nvim")
time([[Config for telescope.nvim]], false)
-- Config for: lualine.nvim
time([[Config for lualine.nvim]], true)
try_loadstring("\27LJ\2\nÖ\1\0\0\6\0\b\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\4\0004\4\3\0005\5\3\0>\5\1\4=\4\5\3=\3\a\2B\0\2\1K\0\1\0\rsections\1\0\0\14lualine_a\1\0\0\1\2\1\0\rdatetime\nstyle\fdefault\nsetup\flualine\frequire\0", "config", "lualine.nvim")
time([[Config for lualine.nvim]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd telescope-project.nvim ]]
vim.cmd [[ packadd telescope-frecency.nvim ]]
vim.cmd [[ packadd plenary.nvim ]]
time([[Sequenced loading]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file NeoTreeFocusToggle lua require("packer.load")({'neo-tree.nvim'}, { cmd = "NeoTreeFocusToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewLog lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewLog", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewOpen lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewOpen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewClose lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewClose", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewRefresh lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewRefresh", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewFocusFiles lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewFocusFiles", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewFileHistory lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewFileHistory", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewToggleFiles lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewToggleFiles", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file UndotreeToggle lua require("packer.load")({'undotree'}, { cmd = "UndotreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file AsyncTask lua require("packer.load")({'asynctasks'}, { cmd = "AsyncTask", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
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

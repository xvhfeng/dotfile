local output_path = "/Users/bgm/works/dotfile/mynvim/keymap.txt"
local modes = { "n", "v", "x", "s", "o", "i", "c", "t" }
local mode_names = {
  n = "普通模式", v = "可视模式", x = "可视字符模式", s = "选择模式",
  o = "操作等待模式", i = "插入模式", c = "命令行模式", t = "终端模式",
}

local sources = {}
for id, path in vim.api.nvim_exec2("scriptnames", { output = true }).output:gmatch("%s*(%d+):%s*(.-)\n") do
  sources[tonumber(id)] = path
end

local function one_line(value)
  return tostring(value or ""):gsub("[\r\n|]", " ")
end

local exact_desc = {
  ["Open"] = "打开", ["Close"] = "关闭", ["Help"] = "帮助", ["Refresh"] = "刷新",
  ["Toggle"] = "切换开关", ["Buffers"] = "已打开缓冲区", ["Quickfix"] = "快速修复列表",
  ["References"] = "查找引用", ["Definitions"] = "跳转定义", ["Implementations"] = "跳转实现",
  ["Diagnostics"] = "诊断信息", ["Marks"] = "书签列表", ["Resume Last"] = "恢复上次操作",
  ["Open Folder"] = "打开目录", ["Open History"] = "打开历史记录",
}

local function chinese_desc(map)
  local raw = one_line(map.desc)
  if raw ~= "" then
    if raw:find("[\228-\233][\128-\191][\128-\191]") then
      return raw
    end
    return exact_desc[raw] or "插件或配置定义的映射"
  end
  if map.callback then
    return "Lua 回调映射"
  end
  if map.rhs and map.rhs:match("^<Plug>") then
    return "插件默认映射"
  end
  return "未提供描述"
end

local function action(map)
  local rhs = one_line(map.rhs)
  if map.callback then
    return "执行 Lua 回调函数"
  end
  local command = rhs:match("<[Cc][Mm][Dd]>(.-)<[Cc][Rr]>") or rhs:match(":(.-)<[Cc][Rr]>")
  if command then
    return "执行命令：" .. command
  end
  if rhs:match("^<Plug>") then
    return "触发插件提供的动作"
  end
  if rhs ~= "" then
    return "重映射为按键序列：" .. rhs
  end
  return "Neovim/插件内建行为"
end

local lines = {
  "# MyNvim 当前全局 Keymap 导出",
  "# 生成时间：" .. os.date("%Y-%m-%d %H:%M:%S"),
  "# 范围：当前启动实例已加载的全局映射；buffer-local 映射依赖文件类型和当前 buffer，未列入。",
  "# 格式：keymap | 来源 | 调用函数 | desc | 作用",
  "",
}

for _, mode in ipairs(modes) do
  local maps = vim.api.nvim_get_keymap(mode)
  table.sort(maps, function(a, b) return a.lhs < b.lhs end)
  table.insert(lines, string.format("## %s（%s，%d 条）", mode_names[mode], mode, #maps))
  table.insert(lines, "keymap | 来源 | 调用函数 | desc | 作用")
  for _, map in ipairs(maps) do
    local info = vim.fn.maparg(map.lhs, mode, false, true)
    local source = sources[info.sid] or (info.sid and "Neovim/插件运行时" or "Neovim 内建")
    local callable = map.callback and "Lua callback" or one_line(map.rhs)
    table.insert(lines, table.concat({
      mode .. " " .. one_line(map.lhs),
      one_line(source),
      callable ~= "" and callable or "内建映射",
      chinese_desc(map),
      action(map),
    }, " | "))
  end
  table.insert(lines, "")
end

vim.fn.writefile(lines, output_path)

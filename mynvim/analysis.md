# Neovim 配置审计分析（报告前置文档）

审计日期：2026-11-22（Asia/Shanghai）

## 结论摘要

这套配置功能覆盖面很广，且在当前机器的 Neovim 0.12.6 上可以完成真实启动；但它尚不属于“最优”状态。主要问题并非某一个插件失效，而是**插件职责重叠、键位来源分散、路径和运行时状态写死、安装职责不清**。这些问题会使启动成本、维护成本和跨机器复现成本都偏高。

隔离状态目录中的实际加载结果为：lazy.nvim 解析到 114 个插件规格、加载了 92 个插件。启动时仅有 fzf-lua 报错；该报错由审计沙箱禁止 Neovim 创建本地 server socket 引起，不能据此判定日常终端中的 fzf-lua 配置有问题。其余配置已无界面启动成功。

建议先做“减法和结构整理”，再新增功能。第一轮目标应是把功能集合收敛到一个搜索器、一个撤销树、一个彩虹括号实现、一个主 Git UI、一个符号大纲和一个文档注释生成器；第二轮再统一键位与自动安装。

## 审计范围与判定依据

已检查 `init.lua`、`lua/core/`、所有已注册的 `lua/plugins/` 模块、`lazy-lock.json`、`deploy.sh` 与现有的键位导出文件。`lua/plugins/ignore/` 是存档/禁用配置，不计入“正在启用”的插件，但它说明旧方案仍残留在仓库中，应在后续整理时移出运行目录或改为明确的 `archive/`。

判定“可精简”并不表示功能一定要删除：若某插件提供了你确定会频繁使用且另一个保留方案无法取代的工作流，则保留它。下表中“建议”以减少重叠和提高可移植性为优先级。

## 配置结构与优先整改项

| 优先级 | 发现 | 依据与影响 | 建议 |
| --- | --- | --- | --- |
| P0 | 配置根目录由用户名拼接 | `init.lua` 把根目录固定为 `/Users/$USER/.config/nvim` 或 `/home/$USER/.config/nvim`。这会绕过 XDG 路径、破坏 Docker/非标准 HOME、也不支持把配置放在别处。 | 用 `vim.fn.stdpath("config")` 作为配置根；插件数据用 `vim.fn.stdpath("data")`，状态/日志用 `stdpath("state")`。 |
| P0 | 插件代码放在仓库内 `reps/` | `lazy.nvim` 的 root 指向 `vim.g.REPSPATH`，首次启动会把 Git clone 写进配置工作树。插件升级、未追踪文件和配置变更互相污染，也不适合容器卷缓存。 | 改为 `stdpath("data") .. "/lazy"`；保留并提交 `lazy-lock.json`，不要提交下载的插件工作树。 |
| P0 | 三套折叠机制叠加 | 全局 `foldmethod=marker`、`nvim-ufo`、`folding-hooks.lua` 同时存在；hook 又调用一次 `ufo.setup()`，并改写 `zf` 与 `<Space>`。 | 常规代码使用 ufo（LSP/Tree-sitter provider）；仅保留 `AddFoldMarkers` 作为显式命令。不要全局改写 `<Space>` 或 `zf`。 |
| P1 | 选项有互相覆盖或过时值 | `lazyredraw` 先为 `true` 后为 `false`；`fileencodings` 设置两次，第二次覆盖了首个更完整的编码表；`completeopt="longest,menu"` 不适合现代补全；`colorcolumn="99999"` 是旧兼容性绕法。 | 每项只保留一处；建议 `completeopt="menu,menuone,noselect"`；删除伪 colorcolumn；以 filetype/EditorConfig 管缩进。 |
| P1 | `autochdir=true` 与项目/LSP 工作目录冲突 | 配置同时使用 project.nvim、Telescope、LSP、Git UI；当前文件目录不断切换会让 root 检测、相对路径任务和 Git 命令不稳定。 | 关闭 `autochdir`，只在需要时对窗口执行 `:lcd %:p:h`，或以项目根目录为 cwd。 |
| P1 | 非可移植命令和个人信息写死 | `term://bash`、Lspsaga 的 `!chrome`、Doxygen 的公司/作者 `db-exp`/`xbgm` 均固定。 | 使用 `vim.o.shell`、`vim.ui.open()` 或系统探测；把个人/公司模板移到 `lua/core/local.lua`（不提交）。 |
| P1 | 配置加载与映射注册分成两套机制 | 一部分键位来自自定义 `core.keymapping` 格式，一部分来自 lazy.nvim `keys`，还有插件内部直接 `vim.keymap.set`。排查覆盖顺序困难。 | 建立 `lua/core/keymaps.lua`：所有自定义键位在此声明，并写 `desc`；lazy 的 `keys` 仅用于惰性加载触发。which-key 会自动读取 desc。 |
| P2 | Tree-sitter 安装会阻塞 UI | `sync_install=true` 会让首次解析器安装占用前台。 | 改为 `sync_install=false`，保留按需或批量安装。 |
| P2 | `autowrite=true` 风险偏高 | 切换 buffer/执行命令时可能无提示写盘，尤其是跨项目批量操作。 | 除非这是刻意的个人工作流，否则关闭，改用显式保存或仅 `autowriteall` 的受控场景。 |

## 已启用插件的功能重叠与精简方案

### 1. 明确重复，建议二选一

| 功能 | 当前重叠 | 建议保留 | 建议移除/停用 | 理由 |
| --- | --- | --- | --- | --- |
| 模糊查找、文件、grep、LSP picker | Telescope + fzf-lua | **fzf-lua** 或 Telescope 任选其一；若偏速度与终端体验，选 fzf-lua | 另一套及其扩展 | 两者都覆盖 files、buffers、grep、diagnostics、LSP symbols/references。当前键位把两套完整暴露，学习成本很高。 |
| 彩虹括号 | `luochen1990/rainbow` + `rainbow-delimiters.nvim` | `rainbow-delimiters.nvim` | `luochen1990/rainbow` | 后者基于 Tree-sitter，已配置独立高亮组；Tree-sitter 的旧 `rainbow` 配置段也应删除。 |
| Undo 历史树 | `undotree` + `vim-mundo` | `undotree` | `vim-mundo` | 二者都是 undo tree UI；Undotree 按命令惰性加载，配置更简单。 |
| 注释/Doxygen 生成 | DoxygenToolkit + Neogen | Neogen；若必须生成 Doxygen license/file header，再保留 DoxygenToolkit 的极小配置 | 另一个 | Neogen 覆盖函数/类/类型/文件注释；DoxygenToolkit 的优势是老式 Doxygen 模板和许可证块。默认双保留造成重复入口。 |
| 代码大纲 | Aerial + Lspsaga outline/finder + 两个 finder 的 LSP symbols | Aerial（常驻侧栏）+ 原生 LSP | Lspsaga 的 outline/finder 部分 | Aerial 同时有 LSP、Tree-sitter、Markdown 后端，适合作为唯一结构视图。 |

### 2. 高度重叠，按工作流选择

| 功能 | 当前插件 | 建议 |
| --- | --- | --- |
| Git 主界面 | lazygit.nvim、Neogit、Fugitive/GV/gitv、vim-flog、tig-explorer、Diffview | 保留 **Neogit + Diffview**（纯 Neovim）或 **lazygit.nvim + Diffview**（偏终端）。Fugitive 可作为少量命令行补充；`vim-flog`、`gitv`/`gv.vim`、`tig-explorer` 是最先可停用的候选。|
| Quickfix | qf-helper、kickfix、preview、Telescope/fzf-lua 的 quickfix picker、Trouble | 选 Trouble 作为诊断/列表 UI，保留原生 quickfix；仅在确有“过滤列表”需求时留下 qf-helper 或 kickfix 之一。 |
| 项目/目录跳转 | project.nvim、autojump、Telescope/fzf-lua 的 cwd 输入、NvimTree | project root 是编辑器语义，autojump 是 shell 历史语义；若只在 Neovim 内跳项目，可停用 autojump 插件和系统依赖。 |
| LSP 操作界面 | 原生 LSP、Lspsaga、goto-preview、Aerial、Trouble、两套 finder picker | 原生 LSP + Aerial + Trouble + 一个 finder 已足够。若保留 Lspsaga，仅留下其 hover/finder/diagnostic 中真正常用的一个两个入口。 |
| 窗口管理 | hydra（未实际定义菜单）、winresizer、maximizer、windowpicker、window.lua、vimade | 保留 windowpicker + maximizer；用真正定义的 Hydra 菜单管理 resize。`window.lua` 若只包装基础 `<C-w>` 可删除，winresizer 和 Hydra 不应同时承担 resize mode。 |

### 3. 依赖或配置层面的冗余

- Neogit 同时把 Telescope 和 fzf-lua 都声明为 optional dependency；在只保留一个 finder 后，应同步删掉另一个依赖。
- `nvim-ufo` 在自身 `config` 和 `folding-hooks` 都执行 setup；保留一处即可。
- `vim-airline` 是 Vimscript 状态栏；它可以继续使用，但如果未来切换 lualine，不能双开。
- `vim-surround`、NERDCommenter、vim-expand-region 等老牌 Vimscript 插件并非错误；只有在希望统一 Lua 生态、减少启动脚本时，再考虑逐项迁移，不建议一次性大改。

## 键位审计与建议的统一方案

### 已确认的问题

1. `q` 被映射为 `<Nop>`，确实能防止误录宏，但也完全移除了宏能力。建议改为保留 `q`，或仅在非显式录制场景用 which-key 提示，而不是永久禁用。
2. `gf` 被 Lspsaga finder 覆盖，失去 Vim 默认“打开光标下文件”的语义；`gx` 被 Lspsaga code action 覆盖，失去 Neovim 默认“打开 URL/URI”语义；这两个默认键应恢复。
3. `K` 先被自定义为插入空行，随后又由 ufo 改成 Lspsaga hover；有效行为取决于加载顺序。`gk` 又被用于原生 hover，违背 Vim/LSP 的常见肌肉记忆。
4. `gq` 被重映射为 diagnostics loclist，覆盖普通模式的格式化操作符；诊断列表应使用 `<leader>xx` 一类前缀。
5. 原生 LSP 使用 `<Space>ca`，而全局 leader 是逗号；同一个 code action 又有 `gx`、`,ca` 等入口。键位不一致且冲突。
6. 键位定义分散在自定义映射框架、lazy 的 `keys`、插件 `config` 和 Vim 插件默认映射中，which-key 展示不一定等于最终实际行为。

### 建议的键位契约

leader 继续用 `,`，localleader 用 `,` 也可工作，但建议 localleader 改为 `\\`，避免全局和文件类型专用键位互相占用。以下是建议的“稳定层”，先与现有映射并存验证，再分批删除旧映射。

| 键位 | 动作 | 理由 |
| --- | --- | --- |
| `K` | `vim.lsp.buf.hover` | 行业惯例，恢复可预期行为。 |
| `gd` / `gD` / `gi` / `gr` / `gy` | definition / declaration / implementation / references / type definition | 和 Neovim 0.11+ 默认 LSP 习惯一致；避免把常用动作塞进 leader。 |
| `gra` | code action | Neovim 现代默认命名；不占用 `gx`。 |
| `grn` | rename | 现代默认命名；可给 `,cr` 再做一个易记别名。 |
| `]d` / `[d` / `gl` | 下/上一个诊断 / 当前行诊断浮窗 | 保留已合理的诊断导航，`ge` 可改为 `gl` 以靠近默认。 |
| `,l` | LSP 功能组 | `,ls` 为 Aerial、`,lx` 为 Trouble、`,lf` 为格式化、`,la` 为 code action。 |
| `,f` | 一个 finder 的文件/搜索功能组 | 例如 `,ff` files、`,fg` live grep、`,fb` buffers、`,fr` resume。删除 `,t*` 与 `,a*` 两套并行前缀。 |
| `,g` | Git 功能组 | `,gg` 主 Git UI、`,gd` Diffview、`,gl` log、`,gb` blame。 |
| `,w` | 窗口功能组 | `,ww` pick、`,wm` maximize、`,wr` 进入 Hydra resize 菜单。 |
| `,u` | Undo 功能组 | `,ut` 切换 Undotree，避免误把 undo tree 放到 Edit/History 的混合路径。 |
| `,c` | 代码编辑 | `,cf` format、`,cc` comment、`,cd` doc comment、`,cr` rename/refactor。 |
| `gf` / `gx` / `gq` / `q` | 保留 Neovim/Vim 默认语义 | 避免为了单个插件牺牲长期肌肉记忆。 |

实现时应让每条 `vim.keymap.set` 都含 `desc`，然后用 which-key 的 `add` 只声明 group；不需要再把相同信息同步进 legendary 式的独立注册结构。

## 菜单：Hydra、which-key 与 Emacs Transient 的对应

当前 `lua/plugins/hydra/init.lua` 只调用了 `require("hydra").setup()`，没有建立 `Hydra({ name, body, heads })`，因此目前没有实际的 Hydra 菜单。Hydra 本身就是最接近 Emacs Transient 的 Neovim 方案：一个 body 进入临时模式，heads 组成可重复执行的动作，hint 窗口充当即时菜单。它适合窗口缩放、Git hunk、diagnostics、quickfix、调试等“进入后连续操作”的场景。官方仓库也将其定位为 custom submodes and menus：<https://github.com/nvimtools/hydra.nvim>。

推荐组合，而不是再安装另一个同类菜单框架：

1. **which-key**：发现型菜单——按 `,` 后展示所有可用后缀，帮助记忆全局键位。它已启用且现代版本会自动读取带 `desc` 的映射：<https://github.com/folke/which-key.nvim>。
2. **Hydra**：操作型临时菜单——仅实现 3–5 个高频 mode，例如 `,wr` 窗口尺寸、`,gD` Git diff、`,lq` diagnostics。每个菜单在 `Esc` 或 `q` 退出。
3. **不推荐同时引入** legendary/wf.nvim/其它“which-key 替代品”。它们会再次拥有一套映射发现逻辑，不能解决当前真正的问题。

建议的窗口 Hydra 结构：`body=",wr"`；`h/j/k/l` 分别缩小/向下增高/向上增高/增宽；`=` 平衡窗口；`o` 最大化；`q`/`Esc` 退出。这样就可以移除或停用 winresizer，并让 `,w` 成为唯一窗口入口。

## 第三方依赖清单

### 基础运行时（所有用户都应安装）

| 组件 | 用途 | macOS Homebrew | Debian/Ubuntu apt |
| --- | --- | --- | --- |
| Neovim >= 0.11 | 当前配置使用 `vim.lsp.config`，本机为 0.12.6 | `brew install neovim` | `sudo apt install neovim`（旧发行版可能版本不足，改用官方 PPA/AppImage） |
| Git >= 2.19 | lazy.nvim 拉取/更新插件 | `brew install git` | `sudo apt install git` |
| 编译工具 | `telescope-fzf-native`、Tree-sitter parser 等原生编译 | `xcode-select --install` | `sudo apt install build-essential` |
| Make / CMake | fzf-native 构建及部分原生插件 | `brew install make cmake` | `sudo apt install make cmake` |
| ripgrep | Telescope/fzf-lua 的文本搜索 | `brew install ripgrep` | `sudo apt install ripgrep` |
| fd | NvimTree 与 finder 的快速文件枚举 | `brew install fd` | `sudo apt install fd-find`；然后 `ln -s $(command -v fdfind) ~/.local/bin/fd` |
| fzf | fzf-lua 的外部模糊匹配器 | `brew install fzf` | `sudo apt install fzf` |
| SQLite3 | Telescope frecency/history 的 SQLite 后端 | `brew install sqlite` | `sudo apt install sqlite3 libsqlite3-dev` |
| Nerd Font | 图标显示（非强制，但当前主题/插件会使用） | `brew install --cask font-jetbrains-mono-nerd-font` | 通过发行版字体包或手动安装 Nerd Font |

### 当前启用插件直接使用的命令行工具

| 工具 | 对应配置/插件 | macOS Homebrew | Debian/Ubuntu apt |
| --- | --- | --- | --- |
| `lazygit` | lazygit.nvim | `brew install lazygit` | `sudo apt install lazygit`（仓库没有时用官方 release） |
| `tig` | tig-explorer | `brew install tig` | `sudo apt install tig` |
| `autojump` | autojump.lua | `brew install autojump` | `sudo apt install autojump` |
| `doxygen` | DoxygenToolkit | `brew install doxygen` | `sudo apt install doxygen` |
| `cpplint` | vim-cpplint | `brew install cpplint` | `sudo apt install cpplint` |
| `jq` | Conform JSON formatter | `brew install jq` | `sudo apt install jq` |
| Python 3 + pipx + pynvim | Python provider、pylsp、格式化器 | `brew install python pipx && pipx install pynvim` | `sudo apt install python3 python3-pip pipx && pipx install pynvim` |
| Node.js LTS + npm | bashls、ts_ls、eslint、yaml/json/vim/sql LSP 与 Prettier | `brew install node` | `sudo apt install nodejs npm`（推荐 NodeSource LTS 以获得新版本） |
| JDK 17+ | jdtls | `brew install openjdk@21` | `sudo apt install openjdk-21-jdk` |
| Go | gopls、goimports、gofumpt 和 Go 项目 | `brew install go` | `sudo apt install golang-go` |
| LLVM/Clang | clangd、clang-format、C/C++ 项目 | `brew install llvm clang-format` | `sudo apt install clangd clang-format` |

`tree-sitter` CLI、`bat`、`delta`、`lolcat`、`ast-grep` 出现在旧 `deploy.sh`，但当前启用配置并不都硬依赖它们；它们应移到“可选开发工具”，不要列为基础安装的必需项。Tree-sitter parser 通常只需要 C 编译器；只有手工生成 grammar 时才需要 tree-sitter CLI。

### LSP 与格式化器

当前 `mason-lspconfig` 明确自动安装的 LSP 是：`lua_ls`、`bashls`、`jdtls`、`clangd`、`cmake`、`eslint`、`ts_ls`、`marksman`、`sqlls`、`yamlls`、`vimls`、`gopls`、`pylsp`。因此优先让 Mason 管它们；Mason 仍依赖上表的 Node、Java、Python、Go/系统运行时，不能把它理解成完全无系统依赖。mason-lspconfig 官方说明 `ensure_installed` 正是用于自动安装 LSP，并在 Neovim 0.11+ 中通过 `automatic_enable` 启用：<https://github.com/mason-org/mason-lspconfig.nvim>。

Conform 当前使用的**非 LSP**格式化器并没有加入 Mason 自动安装：

| 格式化器 | 推荐安装方式 |
| --- | --- |
| stylua | `brew install stylua`；Linux 推荐 `cargo install stylua`（apt 版本可能较旧） |
| goimports、gofumpt | `go install golang.org/x/tools/cmd/goimports@latest`；`go install mvdan.cc/gofumpt@latest` |
| prettier/prettierd | `npm install -g prettier @fsouza/prettierd` |
| ruff、black、isort | `pipx install ruff`、`pipx install black`、`pipx install isort` |
| clang-format | 上表 LLVM 安装命令 |
| jq、codespell | `brew install jq codespell` / `sudo apt install jq codespell` |

## 自动安装的实现建议

### 分层原则

不要让一个 `deploy.sh` 同时无条件执行 Homebrew、apt、sudo、npm、pip、Cargo 和 Go。应拆成以下四层，并要求脚本可重复运行：

1. `scripts/install-system.sh`：识别 `brew` 或 `apt-get`，仅安装基础工具；支持 `--dry-run`，不写 shell rc。
2. `scripts/install-language-tools.sh`：按已启用语言选择 Node/Python/Go formatter；优先 `pipx` 和版本可控的 `go install module@version`。
3. Neovim 内的 `mason-tool-installer.nvim`：统一声明 LSP、formatter、linter，启动时/显式命令安装 Mason 包。
4. `scripts/bootstrap-nvim.sh`：执行 `nvim --headless "+Lazy! sync" "+MasonToolsInstallSync" +qa`。仅在基础运行时已存在、网络可用时运行。

Mason 可以管理 LSP、formatter、linter、DAP 等工具；要覆盖 Conform 的 formatter，需要新增 `WhoIsSethDaniel/mason-tool-installer.nvim`，并把 `stylua`、`gofumpt`、`goimports`、`prettierd`、`prettier`、`ruff`、`black`、`isort`、`clang-format`、`jq`、`codespell` 放入它的 `ensure_installed`。Mason 的 registry 是可查询的包源：<https://mason-registry.dev/registry/list>。

建议的伪代码（实际实施前需先确定是否将所有 formatter 都交给 Mason）：

```lua
require("mason-tool-installer").setup({
  ensure_installed = {
    "stylua", "gofumpt", "goimports", "prettierd", "prettier",
    "ruff", "black", "isort", "clang-format", "jq", "codespell",
  },
  run_on_start = false,
})
```

`run_on_start=false` 的原因是避免每次启动编辑器都做网络安装；应由首次 bootstrap 或显式 `:MasonToolsInstall` 负责。对于 `jdtls`、Node LSP、Python LSP 等，仍需保留对应系统运行时。

## Docker：可在任意机器使用的开发环境

### 推荐架构

不要把容器做成“把整个 `reps/` 和所有缓存烘进镜像”的一次性快照。建议用三层状态：

```text
镜像（不可变）
  └─ OS + Neovim + 系统运行时 + 基础命令
配置仓库挂载（只读为佳）
  └─ init.lua、lua/、lazy-lock.json、脚本
命名数据卷（可更新）
  └─ lazy 插件、Mason 包、Tree-sitter parser、state/cache
项目目录挂载（读写）
  └─ /workspace
```

前提是先把插件根从仓库 `reps/` 迁到 `stdpath("data")`；否则容器的插件更新会直接修改配置仓库，失去分层价值。

### Dockerfile 草案

以下示例以 Debian bookworm 为基础；它是实现方案，不应在未完成上述路径重构前直接投入使用。

```dockerfile
FROM debian:bookworm

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git make cmake build-essential \
    ripgrep fd-find fzf sqlite3 jq \
    python3 python3-pip pipx nodejs npm \
    openjdk-21-jdk golang-go clangd clang-format \
    lazygit tig doxygen cpplint bash \
 && rm -rf /var/lib/apt/lists/*

# Debian stable 的 Neovim 可能低于 0.11；生产镜像应在此安装官方 0.12+ release。
# RUN curl -L .../nvim-linux-x86_64.tar.gz | tar -xz -C /opt \
#  && ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

ENV XDG_CONFIG_HOME=/config XDG_DATA_HOME=/data XDG_STATE_HOME=/state XDG_CACHE_HOME=/cache
WORKDIR /workspace
ENTRYPOINT ["nvim"]
```

首次启动/更新时以一次性 bootstrap 容器处理，而不是让交互式 nvim 每次启动自更新：

```bash
docker run --rm -it \
  -v "$PWD:/config/nvim:ro" \
  -v mynvim-data:/data \
  -v mynvim-state:/state \
  -v mynvim-cache:/cache \
  mynvim:latest \
  --headless '+Lazy! sync' '+MasonToolsInstallSync' '+qa'
```

日常编辑命令（Linux）应传递当前用户 UID/GID，防止挂载项目被 root 写入：

```bash
docker run --rm -it --user "$(id -u):$(id -g)" \
  -v "$PWD:/workspace" \
  -v /path/to/mynvim:/config/nvim:ro \
  -v mynvim-data:/data -v mynvim-state:/state -v mynvim-cache:/cache \
  mynvim:latest README.md
```

macOS Docker Desktop 下也可挂载项目和命名卷，但容器不会天然访问 macOS 剪贴板、钥匙串、GUI 浏览器或宿主机 Docker socket；这些功能应做成可选集成，不能假定总是存在。终端图标字体也由宿主终端安装，而不是容器安装。

### 插件、配置和镜像更新流程

1. 配置变更：提交 `init.lua`/`lua/`/脚本/`lazy-lock.json`；启动容器挂载新配置并运行 bootstrap。
2. 插件更新：在受控环境执行 `:Lazy update`，审阅变更和启动测试后提交新的 `lazy-lock.json`；其他机器只执行 `:Lazy sync`，不自行漂移版本。lazy.nvim 的 lockfile 正是为此目的设计，默认位置也是配置目录中的 `lazy-lock.json`：<https://github.com/folke/lazy.nvim>。
3. Mason 更新：将工具集合声明在 `mason-tool-installer`；数据卷可保留已下载包。需要可复现时，在镜像/脚本中记录 Mason registry revision 或定期重建卷并做 smoke test。
4. 系统依赖更新：更新 Dockerfile 的基础镜像和版本，构建带日期或 Git SHA 的镜像标签；不要在运行中的编辑容器里 `apt upgrade`。
5. 验证：每次更新运行 `nvim --headless '+Lazy! sync' '+checkhealth' '+qa'`，再打开 Lua、Go、Python、C++、Java、YAML 五类样本文件检查 LSP/formatter。

## 推荐新增的插件（在精简完成后再选择）

| 优先级 | 插件 | 适用条件 | 为什么推荐 |
| --- | --- | --- | --- |
| 高 | `WhoIsSethDaniel/mason-tool-installer.nvim` | 你采纳自动安装方案 | 把当前分散的 LSP/formatter 安装收敛为声明式清单。 |
| 高 | `stevearc/conform.nvim` 的现有配置完善即可 | 已启用 | 不需新插件；补齐工具安装与 `format_on_save` 的项目级开关，比另装 formatter 框架更好。 |
| 中 | `folke/flash.nvim` | 若想替换 Hop | 提供更现代的跳转/搜索交互；只能在停用 Hop 后引入，避免两套 motion 插件。 |
| 中 | `folke/trouble.nvim` 的现有配置完善即可 | 已启用 | 不需新插件；将其作为唯一 diagnostics/quickfix UI，能减少 qf-helper/kickfix/preview 重叠。 |
| 中 | `lewis6991/gitsigns.nvim` | 希望在 gutter 快速看/操作 hunk | 当前 Git 工具多但缺少轻量行级 hunk 操作；引入前应先缩减 Git UI。 |
| 低 | `nvim-lualine/lualine.nvim` | 想从 vim-airline 迁移到 Lua | 仅作为替换，不与 airline 并用。 |

不推荐在当前状态下继续新增 finder、Git UI、outline、menu 或 undo 插件；它们都会放大现有重叠。

## 建议的实施顺序（供最终报告/改造阶段采用）

1. 备份并提交当前可工作的 `lazy-lock.json`；建立 headless 启动检查。
2. 修正路径：全量改用 `stdpath()`，并将插件下载目录从 `reps/` 迁出仓库。
3. 先删四组明确重复：rainbow、undo tree、finder、Doxygen/Neogen；每组停用后人工使用一周再删除文件。
4. 收敛 Git、Quickfix/LSP UI 和窗口管理。
5. 统一键位契约，先恢复 `gf`、`gx`、`gq`、`K`，再迁移到单一 `keymaps.lua`。
6. 引入 Mason tool installer 和跨平台安装脚本，淘汰当前只支持 Homebrew、且会直接写 `.bashrc` 的 `deploy.sh`。
7. 在路径重构后补 Dockerfile、bootstrap 脚本和 CI/headless smoke test。

完成以上步骤后，再生成 `report.txt`：它应包含最终保留/删除清单、已执行改动、最终依赖列表和可直接运行的安装脚本，而不是重复本分析文档中的备选方案。

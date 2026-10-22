# Emacs 配置项目执行准则

本文件是本仓库后续维护的唯一项目级准则。任何 Agent 在修改配置、安装插件、排障、测试或执行命令前，均应先阅读并遵守本文件；当次用户的明确要求优先。

目标是稳定、可发现、低记忆负担且适合长期多语言开发的 Emacs，而不是堆叠插件。

## 1. 工作方式与改动边界（强制）

1. 先读相关配置、测试、调用链、错误日志与 `git diff`；复现并确认根因后，以最小改动修复。禁止凭报错猜测、反复叠加 hook/advice 或用 `ignore-errors` 掩盖问题。
2. 用户目标明确时直接完成；只有会明显扩大范围、修改外部数据、需要系统权限或确实缺少关键选择时才说明阻塞。
3. 未获明确授权不得改变无关快捷键、命令行为、主题、插件、用户数据或已正常工作的功能。用户要求“只修复某问题”时严格限制改动范围。
4. 保留用户已有未提交修改、私有文件、运行时数据与工作区状态；禁止 `git reset --hard`、覆盖式 checkout、宽泛删除或为干净环境破坏现状。
5. 每次修改 Elisp，新增逻辑、兼容处理、延迟加载原因和非直观设置应有中文注释；菜单和用户可见文字优先使用中文。
6. 不把告警静默压掉：`Cannot load`、启动警告、宏展开失败、字节编译失败、失效 keymap/Transient 后缀都要定位并解决根因。
7. 最终结论只报告实际改动、实际命令输出验证与仍存在的限制，不能以“应该可用”代替验证。

## 2. 快捷键、菜单与个人工作台（强制同步）

新增、删除、迁移或修改交互命令/快捷键/菜单时，必须逐项检查并同步适用入口：

1. 实际命令和 keymap；
2. General；
3. Which-Key 的中文说明；
4. 对应 Transient；
5. 个人工作台 `C-d` 与 `C-c SPC`。

规则：

- 尽量保留 Emacs 原生 `C-`、`M-` 加字母、数字或符号的绑定；只有用户明确指定的例外才覆盖。替代或删除命令时移除失效入口，保留仍有效的原生命令。
- 配置中的所有自定义键位必须由 General 定义，并能在 Which-Key 中发现；Which-Key 是统一菜单入口，每一级 prefix 都必须有清晰的中文说明。
- 键位尚未明确时，优先使用小写字母或无需按 `Shift` 的符号。
- Transient 后缀命令必须已定义或有可靠 autoload；在 Scratch、未打开语言文件、未启动 Eglot 时工作台仍须能打开，不能出现 `Suffix command ... is not defined or autoloaded`。
- 工作台是高频的首要发现入口。菜单应宽阔整齐，列标题、子项起点与间距对齐，避免描述错位或拥挤换行。
- 工作台维护文件/搜索、代码大纲/诊断、编辑跳转、项目/Git、Diffnav、文件树、临时窗口、笔记/日程、帮助发现和 vterm 终端等高频入口；终端复用现有 vterm，不另起 term/shell 体系。
- 不覆盖用户已定制键位：`C-t` 保持 `kill-region`，窗口操作使用 `C-w` 体系且不在工作台重复放置。
- 个人工作台不能因延迟加载、过期字节码或 Transient 校验而失效。

## 3. 按键与交互兼容性（不得回归）

1. 物理 `ESC` 全局用于退出所有可退出的窗体、临时窗口和菜单，以及取消进行中的命令；以后新增插件也必须遵守，不再用 `ESC` 打开工作台。`C-g` 必须保留取消功能。vterm 对 `ESC`、`BS`、`DEL` 的特殊处理只能 buffer-local，不能污染全局、Which-Key 或 Transient。
2. 多级菜单中 `BS` 默认返回上一层，Which-Key 的 `DEL` 也回退一层；仅在根层退出。用户对某键的显式功能绑定优先。
3. Treemacs 中 `j`/`k` 分别等同 `C-n`/`C-p`。
4. 平滑翻页保持：`C-8`/`C-7` 平滑整页并保留 5 行上下文，`C-0`/`C-9` 平滑半页，`C-v`/`M-v` 保留原生行为；自定义翻页后光标保持相对窗口行位置。
5. `server-mode` 放在 `init.el` 的运行期配置，不放入 `early-init.el`；完整重载配置必须可用且避免重复加载已知副作用状态文件。
6. `C-d` 全局切换个人工作台，`C-j` 全局切换 Pinky；`C-w` 是窗口菜单，顶层 `a/d/w/s` 向左/右/上/下分屏且保留原窗口焦点，`f/b/n/p` 向右/左/下/上分屏并切换，`q` 关闭当前窗口。

## 4. 插件、运行时目录与加载（强制）

1. 第三方包统一由 Straight 管理；不引入第二套包管理器。仓库本地插件使用 `use-package` 并标记 `:straight nil`。
2. 插件构建产物、缓存、Mason/LSP 工具、Tree-sitter grammar、Transient 状态等全部进入 `runtimes/`。外部可执行文件放仓库根目录 `runtimes/bin/`。不得重新散落到配置根或不受管目录。
3. 新机器启动必须自动拉取、构建和加载所需 Emacs 包；Mason与treesitter 及可管理工具也必须在启动期安装或明确报告真实失败原因。
4. 新插件前先确认现有内置/插件不能满足，随后确认包名、feature、命令、宏、系统依赖、可执行文件、运行时路径与缺失时的退化方式。
5. 需要 Homebrew 或其他系统级依赖时，在用户授权范围内安装并记录用途、安装命令和缺失影响。
6. `.el` 新于 `.elc` 时先加载源码完成依赖安装，再更新字节码；有效 `.elc` 较新时优先加载。禁止重新启用强制加载过期字节码的旧逻辑。
7. 当前 Ranger 配置可保留在磁盘，但不参与启动或快捷键入口；文件管理器使用 Dirvish。

## 5. 字节编译、宏与延迟加载（高频必检）

1. `early-init.el` 的受管字节编译器必须只在**编译阶段**将 `runtimes/straight/build/` 下所有已构建插件目录放入 `load-path`。这是防止 Consult、Transient、General 等宏/扩展在 eager macro-expansion 阶段找不到的通用机制。
2. 新插件若提供宏、`use-package` 扩展关键字或编译期函数，必须验证编译时能解析，不能只验证交互运行时。
3. 运行时仍使用 `use-package`、autoload 与 buffer-local hook；不能为了编译通过而全局提前 `require` 大型包、拖慢启动或增加副作用。
4. 仅在通用编译保护不足时才在局部使用 `eval-when-compile`，并用中文说明原因。
5. 新插件、编译或可选依赖产生的警告必须修复而非静默忽略；可选插件安装失败时主流程应安全退化。

## 6. 多语言、项目、LSP 与诊断（强制）

1. `lang/` 内已有和后续新增语言遵循同一渐进架构：统一项目根、Tree-sitter、补全、Eglot/LSP、Flymake、outline 与必要格式化能力，不能只对 C/Java/Elisp 写死。
2. 项目根优先向上找 `.projx`，再使用 Emacs/project 默认规则（如 `.git`）；均找不到则当前目录是根。LSP、Tree-sitter、补全、搜索与项目命令共享这一判定。
3. 保持使用 Eglot；单个 server 故障按“项目根 → 可执行文件 → 参数/日志 → capability → buffer-local mode”排查，不直接替换为 lsp-mode。
4. C/C++ 优先使用 `/opt/homebrew/opt/llvm/bin/clangd`，避免 Apple clangd 的既有 status 11 崩溃。
5. Eglot 管理的 C/C++ 不得并行启用 `flymake-cc`；使用 Eglot/Flymake 标准链，避免 `flymake--state` 错误。其他语言尽力启用 Flymake，未配置诊断器可安全无诊断但不能被错误全局禁用。
6. C 宏、别名类型与自定义修饰符的 clangd 误报优先修真实 `compile_commands.json`、include、宏定义和标准参数，不能用 Emacs 忽略诊断替代。
7. 格式化统一对整个 buffer 使用 `indent-region`，无论文件大小、语言或选区；不得恢复 LSP document formatting 或按行数分支。
8. HTML/Web、Tree-sitter 与 LSP 的能力缺失先核对 grammar/服务器真实支持；大文件、候选列表和诊断不能因重复启动、同步格式化或预览而卡顿。

## 7. 大纲、文件管理、编辑与界面体验（强制）

1. Outline 优先使用 LSP/Imenu 的函数、变量、类型等分类信息；`consult-imenu`、`imenu-list`/智能大纲应按可用能力安全退化。
2. Treemacs 使用 marker 和位置整数时均须做合法性处理；空大纲、过期 marker 或无 LSP buffer 必须安全退化，避免向 marker API 传整数。
3. `consult-recent-file` 与 `consult-find` 默认关闭自动预览，避免候选移动卡顿；其他 Consult 昂贵预览保留约 1 秒防抖，不恢复即时预览。
4. Dirvish 是当前文件管理器：保持多栏及足够列宽、行/光标高亮、详情、图标、Git 集成、帮助与定位键进入目录；默认关闭预览，提供显式按键按需预览。不得让工作台 `C-d p m` 或旧 Ranger 入口退化为 Dired。
5. Iedit 的 `M-;` 保持注释代码行为，不被 Iedit 编辑绑定覆盖。
6. 手工折叠支持全 buffer toggle：任一折叠展开则全部折叠，全部折叠才展开；支持独立行和内联 `{{{`/`}}}`，包含 C 注释和同一行代码。工作台 `C-d → c f → a` 必须可用。
7. 通用配对选择/跳转支持 `()[]{}` 与 HTML/XML 标签，不能只支持单一语言。
8. 缩进辅助显示低对比、细灰白 `|`；光标为紫红色 box，当前行明显但不刺眼。

## 8. 终端、Git、Magit、Diffnav 与冲突（强制）

1. 常用终端为 vterm：在项目/当前目录启动，保留 Bash、原生渲染、滚动历史和 `exit` 后自动关闭 buffer。避免新增会闪烁或退出不关闭的 term 流程。
2. Diffnav 使用本地 `plugins/diffnav-emacs` 与 vterm 后端。按 `q` 后必须 kill 承载 Diffnav 的 vterm buffer，并返回启动来源 buffer。
3. Diffnav 运行管道应通过 `exec /bin/sh -c <完整 shell-quote 命令>`，不能仅 exec 管道左侧 git，否则无法正常退出。
4. Diffnav 的工作台、Transient、Which-Key 提供用户可理解的比较项；当前文件仅显示与 Git 状态匹配的操作。
5. Magit 提交通过运行中的 Emacs server/emacsclient 编辑提交信息；socket 或 WITH-EDITOR 错误先修 server/环境，而不是让用户绕开 Magit。
6. `smerge-mode` 自动识别冲突，保留 `C-c ^` 并提供 Transient/工作台/Which-Key；普通文件禁用相关项而不报错。

## 9. 模板、输入法、主题与临时窗口（强制）

1. 模板置于根目录 `template/`，逻辑在 `user-lisp/init-template.el`；维护 C/C++、Go、Java、TypeScript 示例，作者/邮箱必须来自可修改变量而非硬编码。
2. 主题使用 Tokyonight，主题模块在 `init-base.el` 后尽早加载，不能破坏初始化顺序。
3. macOS 输入法 source ID 去重；调用平台函数前检测其是否存在，并对不支持环境安全退化。
4. Popper 管理 Help、编译、Flymake diagnostics、grep、Messages 等临时 buffer，并可由工作台调用；验证时实际测试受管 buffer 的打开、隐藏和切换。

## 10. 性能原则（强制）

1. 优化启动与交互速度但绝不以破坏功能、键位或可发现性为代价。
2. 避免全局 advice、重复 hook/重复 mode 启动和无条件 require；优先 buffer-local hook。
3. 大文件、诊断、搜索候选和文件预览不得引发无响应；先消除不必要的同步 I/O、自动预览和重复 LSP/格式化。

## 11. 每次变更后的验证清单（强制）

按实际改动执行并在结果中报告：

1. `git diff --check`。
2. 新行为先写最小会失败的回归测试，再实现并通过；受影响模块运行现有 ERT/相关测试。
3. 对修改 Elisp 执行受管字节编译或批处理加载，确认没有语法、宏展开、void-function 或旧 `.elc` 问题。
4. 影响启动/顺序时，使用 `emacs --batch -Q` 加载 `early-init.el` 与 `init.el`，确认没有包管理、模块、`Cannot load` 或启动警告。
5. 影响快捷键、工作台、Transient 或延迟加载时，确认命令可调用、autoload 有效、Scratch 可打开菜单，且 General/Which-Key/工作台入口同步。
6. 外部工具验证 `executable-find`、版本和最小真实调用；语言模式至少在对应 buffer 验证受影响的 LSP/Flymake/Tree-sitter/outline/格式化能力。
7. vterm、Diffnav、Popper、Magit 等交互流程如无法批处理完整覆盖，提供并执行明确手工验证路径，不可仅凭配置加载成功就宣称修复。
8. 无关脏文件不清理；最终区分本次改动与既有改动。

## 12. 新插件/新功能接入顺序（强制）

1. 阅读本文件、关联 init、调用链、测试和当前 diff。
2. 确定根因或需求边界，优先复用现有插件/命令。
3. 确认包、feature、命令、宏、系统依赖、运行时位置及退化策略；使用 Straight 与 `runtimes/` 规范接入。
4. 新行为先补最小失败测试；以中文注释实现最小兼容方案。
5. 若涉及交互功能，同步实际 keymap、General、Which-Key、Transient、个人工作台。
6. 执行第 11 节验证后再报告。替代旧插件时，先停止旧插件启动加载与入口；保留或删除旧配置必须按用户指示。

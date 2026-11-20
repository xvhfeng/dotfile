# Org 实施方案与使用手册

> 状态说明：**现有**表示此前已有；**新增**表示本次接入。PDF 使用 Homebrew 安装的 Tectonic；首次编译可能需要下载 TeX 宏包。

## 1. 目标与现状

使用 Org 管理日程、TODO、笔记、项目文档、设计文档和用户手册；以日、周、月三个维度查看安排，并在 Agenda 中编辑任务；支持提醒、HTML/PDF/EPUB 导出、图片、清晰的界面，以及 Which-Key 和 Transient 菜单。

当前配置已经有 Org、Agenda、Capture、Clock、Org Modern、Consult、Which-Key 和个人工作台。`~/org/` 是统一的 Org 文档根目录；已有 `inbox.org`、`gtd.org`、`notes.org`、`journal.org` 四种 Capture 目标。现有默认 Agenda 跨度是 10 天，从三天前开始。既有文件、模板和按键保持原样。

## 2. 完整实施方案

### 2.1 插件与依赖

| 项目 | 处理 | 用途 |
|---|---|---|
| `org-ql` | Straight 安装，命令按需加载 | 跨文件查询任务和文档条目 |
| `org-appear` | Straight 安装，仅在 Org buffer 启用 | 编辑时显示光标所在处被隐藏的链接、强调标记 |
| `org-download` | Straight 安装，仅用于 Org buffer | 插入截图、剪贴板图片、图片地址 |
| `ox-epub` | Straight 安装，在 Org 导出入口加载 | EPUB 导出 |
| `org-modern` | 已安装，保留 | Org 与 Agenda 的现有外观 |
| `org-agenda-to-appt`、`appt` | Emacs/Org 内置 | 预约提醒 |
| Org HTML/LaTeX 导出 | 内置 | HTML 与 PDF；PDF 还需本机 LaTeX |
| Emacs Calendar | 内置 | 月历网格和日期选择 |

本阶段不安装 `org-roam`、`denote`、`org-super-agenda`、`org-rifle`、`ox-hugo`、`org-re-reveal`、`ob-async`、`org-anki` 或 `anki-editor`。现有 Capture 和 Agenda 可以覆盖当前日程与文档需求；知识库、Hugo 网站、幻灯片和 Anki 工作流出现明确需求后再评估。

### 2.2 文件与目录

| 路径 | 本次改动 |
|---|---|
| `user-lisp/init-org.el` | 声明插件；配置图片、提醒、视图、导出；定义 Org 工作台及 General/Which-Key 键位；补充中文说明 |
| `user-lisp/init-workbench.el` | 在 `C-d` 顶层增加单字符 `x`，打开完整 Org 工作台；保留 `l` Capture 和 `g` Agenda |
| `~/org/` | 所有 `.org` 文档的统一根目录，不迁移现有文件 |
| `~/org/docs/` | 项目文档、设计文档、用户手册，可按项目分子目录 |
| `~/org/assets/` | Org 文档引用的截图和图片 |

Agenda 沿用现有根目录文件范围，`docs/` 子目录不纳入默认 Agenda；`org-ql` 会递归查询整个 `~/org/`。缓存与插件构建产物继续放仓库的 `runtimes/`，不写入文档目录。

### 2.3 完整 Org 工作台

`C-d → x` 打开 Org 的二级 Transient 工作台。各组再进入子菜单，所有命令使用中文说明，列宽与现有工作台对齐。`ESC` 退出，`BS` 返回上级，遵循现有菜单习惯。

| 入口 | 组 | 子键与工作 |
|---|---|---|
| `C-d x a` | 日程与 TODO | `d` 日视图、`w` 周视图、`m` 月视图、`c` 月历网格、`g` 月历所选日期的 Agenda、`t` TODO 列表、`r` 刷新提醒 |
| `C-d x c` | Capture | `i` 收件箱、`t` TODO、`n` 笔记、`j` 日志；复用现有模板 |
| `C-d x s` | 标题与结构 | `n` 同级标题、`c` 子标题、`t` TODO 标题、`p/d` 提升/降低层级、`u/j` 上移/下移子树、`f` 折叠当前标题、`v` 切换全文显示、`a` 归档、`k` 剪切 |
| `C-d x d` | 文档与导出 | `n` 新建带元数据的 Org 文档、`o` 打开文档、`e` 导出菜单、`h` HTML、`p` PDF、`u` EPUB |
| `C-d x q` | 查找 | `h` 当前文档标题、`q` 跨文件查询 |
| `C-d x i` | 图片 | `c` 剪贴板图片、`s` 截图、`y` 图片地址 |
| `C-d x k` | 计时 | `i` 开始、`o` 结束、`g` 跳转到计时任务、`c` 取消 |

菜单中的 Org 编辑与导出项仅在适用的 Org buffer 中执行；其他位置显示明确提示。工作台在 Scratch 中仍能打开，延迟加载的命令须有可靠 autoload。

### 2.4 日、周、月与提醒

日/周/月 Agenda 从任意 buffer 打开，分别从今天、本周一、本月一日开始，不修改现有默认 10 天 Agenda。月 Agenda 是按日期排列的事项列表；月历网格由 Emacs Calendar 提供。月历选定日期后，使用 `org-calendar-goto-agenda` 打开该日安排。

Agenda 中保留现有 `t` 改 TODO、`s` 设计划、`d` 设截止、`q` 改标签、`r` 移动条目、`RET` 打开原文、`C-SPC` 预览。尤其不能把 `d` 改为日视图，因为当前用户配置已把它用于截止日期。日/周/月入口放在 Org 工作台和新的 `C-c n v` 前缀中。

启动时从 Agenda 中带具体时刻的事项生成 `appt` 提醒；相关 Org 任务保存后做防抖刷新，并提供手动刷新键。提醒仅在 Emacs 运行时生效。计划时间、截止日期与带时刻的预约应在手册中明确区分。

### 2.5 导出与图片

保留 `C-c C-e` 和 `C-c n e` 的 Org 导出入口；加入 EPUB，并在工作台提供 HTML、PDF、EPUB 直达命令。HTML 使用 Org 内置后端；PDF 通过 LaTeX；EPUB 使用 `ox-epub`，需检查 `zip`。EPUB 文档模板包含标题、作者、日期、唯一标识等必要元数据。

图片存放在 `~/org/assets/`，插入相对链接。截图使用 macOS 自带 `screencapture`；剪贴板图片使用 Homebrew 的 `pngpaste`。没有可供自动测试的实际剪贴板图片或图形截图操作，需在 Emacs 图形界面试用这两个入口。

### 2.6 实施与验收

1. 先为新增行为写最小回归检查，再添加配置。
2. 验证 Straight 在新环境能自动取得插件，且启动不出现 `Cannot load`、宏展开或过期字节码问题。
3. 验证 `C-d x`、各级 Transient、General 和 Which-Key 中文说明；保留既有 `C-d l/g` 与 `C-c n` 行为。
4. 从 Scratch 打开工作台；在 Org buffer、Agenda、Calendar 中分别验证适用命令。
5. 验证日/周/月与月历选日期、Agenda 内任务编辑、提醒刷新、图片插入，以及 HTML/PDF/EPUB 实际导出。
6. 执行 `git diff --check`、Elisp 批处理加载/编译和受影响模块测试；报告实际结果与剩余依赖。

## 3. Org 使用手册

### 3.1 快速开始与文件

| 文件 | 用途 | Capture 选择 |
|---|---|---|
| `~/org/inbox.org` | 临时收集内容 | `i` |
| `~/org/gtd.org` | TODO 与项目任务 | `t` |
| `~/org/notes.org` | 普通笔记 | `n` |
| `~/org/journal.org` | 按日期记录日志 | `j` |
| `~/org/docs/项目名/design.org` | 设计文档 | 新增的文档入口打开 |
| `~/org/docs/项目名/manual.org` | 用户手册 | 新增的文档入口打开 |

日常路径：Capture 收集任务 → 在 Org 文件中补充标题、计划和截止日期 → Agenda 查看日程 → 在 Agenda 中修改状态或跳到原文 → 完成后归档。Capture 中通常按 `C-c C-c` 完成、`C-c C-k` 取消。

### 3.2 全局、Which-Key 与工作台键位

| 键位 | 状态 | 命令/入口 | 能完成的工作 |
|---|---|---|---|
| `C-d` | 现有 | `my/workbench` | 打开个人工作台 |
| `C-d l` | 现有 | `org-capture` | 快速捕获 |
| `C-d g` | 现有 | `org-agenda` | 查看默认 Agenda |
| `C-d x` | 新增 | Org Transient 工作台 | 进入全部 Org 菜单 |
| `C-c n a` | 现有 | `org-agenda` | 查看默认 Agenda |
| `C-c n b` | 现有 | `org-switchb` | 切换 Org buffer |
| `C-c n c` | 现有 | `org-capture` | 选择 Capture 模板 |
| `C-c n e` | 现有 | `org-export-dispatch` | 打开导出菜单 |
| `C-c n f` | 现有 | `my/org-open-inbox` | 打开收件箱 |
| `C-c n l` | 现有 | `org-store-link` | 保存当前位置链接 |
| `C-c n t` | 现有 | `org-todo-list` | 显示全部 TODO |
| `C-c n d` | 新增 | `my/org-create-document` | 在 `~/org/docs/` 新建带导出元数据的文档 |
| `C-c n v d/w/m` | 新增 | 日/周/月 Agenda 命令 | 按对应时间跨度查看安排 |
| `C-c n v c` | 新增 | `calendar` | 打开月历网格 |
| `C-c n q` | 新增 | `org-ql-search` | 跨 Org 文件查询 |
| `C-c n h` | 新增 | `consult-org-heading` | 定位当前文档标题 |
| `C-c n r` | 新增 | `org-agenda-to-appt` 包装命令 | 刷新提醒 |
| `C-c n i` | 新增 | `org-download-clipboard` | 插入剪贴板图片 |
| `C-c n p` | 新增 | `org-download-screenshot` | 截图并插入 |

`C-d x` 的所有后续按键见 2.3 节。工作台的 `C-d x c i/t/n/j` 与直接 Capture 后选 `i/t/n/j` 使用同一模板。

### 3.3 标题、层级、移动、折叠

```org
* 项目 A
** 设计文档
*** 接口设计
** 开发任务
*** TODO 完成接口
```

| 键位 | 状态 | 命令 | 能完成的工作 |
|---|---|---|---|
| `C-RET` | 现有 | `org-insert-heading-respect-content` | 新增标题 |
| `C-M-RET` | 现有 | `org-insert-subheading` | 新增子标题 |
| `C-S-RET` | 现有 | `org-insert-todo-heading-respect-content` | 新增 TODO 标题 |
| `TAB` | 现有 | `org-cycle` | 折叠/展开当前标题 |
| `S-TAB` | 现有 | `org-shifttab` | 循环全文显示状态 |
| `M-←/→` | Org 原生 | `org-metaleft` / `org-metaright` | 根据光标位置调整标题或列表层级 |
| `M-↑/↓` | Org 原生 | `org-metaup` / `org-metadown` | 根据光标位置移动标题或列表项 |
| `C-c n s n/c/t` | 新增 | 对应标题插入命令 | 从 Which-Key 新增同级/子/TODO 标题 |
| `C-c n s p/d` | 新增 | `org-promote-subtree` / `org-demote-subtree` | 提升/降低整个子树层级 |
| `C-c n s u/j` | 新增 | `org-move-subtree-up` / `org-move-subtree-down` | 上移/下移整个子树 |
| `C-c n s f/v` | 新增 | `org-cycle` / `org-shifttab` | 折叠当前标题/切换全文显示 |
| `C-c n s a` | 现有 | `org-archive-subtree-default` | 归档当前子树 |
| `C-c n s k` | 现有 | `org-cut-subtree` | 剪切整个子树 |

### 3.4 TODO、时间、标签和链接

```org
* TODO 写用户手册
SCHEDULED: <2026-11-23 Mon 10:00>
DEADLINE: <2026-11-27 Fri>
```

当前状态序列为 `TODO`、`PROJ`、`STRT`、`WAIT`、`HOLD`、`IDEA`，完成态为 `DONE`、`KILL`，实施时不改变。

| 键位 | 状态 | 命令 | 能完成的工作 |
|---|---|---|---|
| `C-c C-t` | 现有 | `org-todo` | 修改 TODO 状态 |
| `C-c C-s` | 现有 | `org-schedule` | 设置计划时间 |
| `C-c C-d` | 现有 | `org-deadline` | 设置截止日期 |
| `C-c C-q` | 现有 | `org-set-tags-command` | 设置标签 |
| `C-c .` | 现有 | `org-time-stamp` | 插入活动时间戳 |
| `C-c !` | 现有 | `org-time-stamp-inactive` | 插入记录用时间戳 |
| `C-c C-l` | 现有 | `org-insert-link` | 插入文件、网页或标题链接 |
| `C-c C-o` | 现有 | `org-open-at-point` | 打开光标处链接 |
| `C-c C-,` | 现有 | `org-insert-structure-template` | 插入源码、引用等结构块 |
| `C-c '` | 现有 | `org-edit-special` | 在对应语言模式编辑源码块 |

### 3.5 日、周、月与日历

| 键位 | 状态 | 命令/入口 | 能完成的工作 |
|---|---|---|---|
| `C-d g` / `C-c n a` | 现有 | `org-agenda` | 打开现有默认 Agenda |
| `C-d x a d/w/m` | 新增 | 指定跨度的 `org-agenda-list` | 打开日/周/月 Agenda |
| `C-c n v d/w/m` | 新增 | 同上 | 无需打开工作台切换视图 |
| `C-d x a c` / `C-c n v c` | 新增 | `calendar` | 查看月历网格 |
| `C-d x a g` | 新增 | `org-calendar-goto-agenda` | 从月历当前日期打开 Agenda |
| `C-d x a t` | 新增 | `org-todo-list` | 查看全部 TODO |
| `C-d x a r` / `C-c n r` | 新增 | 提醒刷新命令 | 重新读取预约 |

月 Agenda 是整月事项**列表**，月历是日期**网格**。在日历中选中日期后可进入当天 Agenda。带具体时刻的事项才能作为预约提醒；提醒在 Emacs 运行期间显示。

### 3.6 Agenda 中查看与编辑

下表以本配置为准：其中 `d`、`q`、`r`、`s` 已有自定义绑定，不能按 Org 上游默认键位理解。

| 键位 | 状态 | 实际命令 | 能完成的工作 |
|---|---|---|---|
| `t` | 现有 | `org-agenda-todo` | 修改 TODO 状态 |
| `s` | 现有 | `org-agenda-schedule` | 修改计划日期 |
| `d` | 现有 | `org-agenda-deadline` | 修改截止日期；不是日视图 |
| `q` | 现有 | `org-agenda-set-tags` | 设置标签；不是退出 |
| `r` | 现有 | `org-agenda-refile` | 移动条目；不是刷新 |
| `RET` | Org 原生 | `org-agenda-switch-to` | 打开原始 Org 条目完整编辑 |
| `C-SPC` | 现有 | `org-agenda-show-and-scroll-up` | 预览原始条目 |
| `g` | Org 原生 | `org-agenda-redo-all` | 刷新 Agenda |
| `c` | Org 原生 | `org-agenda-goto-calendar` | 从当前日期进入月历 |
| `n/p` | Org 原生 | `org-agenda-next-line` / `org-agenda-previous-line` | 移动到下/上一行 |
| `f/b` | Org 原生 | `org-agenda-later` / `org-agenda-earlier` | 查看下一/上一时间段 |
| `.` | Org 原生 | `org-agenda-goto-today` | 回到今天 |
| `ESC` | 现有全局习惯 | 退出可退出窗口或取消 | 离开当前临时界面 |

### 3.7 文档、图片、查询与导出

| 键位 | 状态 | 命令/入口 | 能完成的工作 |
|---|---|---|---|
| `C-d x d n` / `C-c n d` | 新增 | `my/org-create-document` | 新建带 EPUB 元数据的文档 |
| `C-d x d o` | 新增 | Org 文档选择命令 | 打开 `~/org/` 下的文档 |
| `C-c n h` / `C-d x q h` | 新增 | `consult-org-heading` | 跳转当前文档标题 |
| `C-c n q` / `C-d x q q` | 新增 | `org-ql-search` | 按 TODO、标签、时间等跨文件筛选 |
| `C-c n i` / `C-d x i c` | 新增 | `org-download-clipboard` | 插入剪贴板图片 |
| `C-c n p` / `C-d x i s` | 新增 | `org-download-screenshot` | 截图并插入 |
| `C-d x i y` | 新增 | `org-download-yank` | 从图片地址插入 |
| `C-c C-e` | Org 原生 | `org-export-dispatch` | 打开导出选择器 |
| `C-c n e` | 现有 | `org-export-dispatch` | 打开同一导出选择器 |
| `C-d x d e` | 新增 | `org-export-dispatch` | 从工作台选择格式 |
| `C-d x d h/p/u` | 新增 | HTML/PDF/EPUB 导出命令 | 直接导出相应格式 |

导出 HTML 使用 Org 内置后端；PDF 使用 Homebrew 的 Tectonic，中文文档模板加载 `ctex`；EPUB 使用 `ox-epub` 和系统自带的 `zip`。含图片、数学公式和特殊字体的文档仍应分别检查导出结果。

### 3.8 计时

| 键位 | 状态 | 命令 | 能完成的工作 |
|---|---|---|---|
| `C-c n k i` / `C-d x k i` | 现有 / 新增 | `org-clock-in` | 开始当前任务计时 |
| `C-c n k o` / `C-d x k o` | 现有 / 新增 | `org-clock-out` | 结束计时 |
| `C-c n k g` / `C-d x k g` | 现有 / 新增 | `org-clock-goto` | 跳转到正在计时的任务 |
| `C-c n k c` / `C-d x k c` | 现有 / 新增 | `org-clock-cancel` | 取消计时 |

## 4. 参考资料

- [Org 官方手册：日程与提醒](https://orgmode.org/manual/Weekly_002fdaily-agenda.html)
- [Org 官方手册：导出](https://orgmode.org/manual/Exporting.html)
- [org-ql](https://github.com/alphapapa/org-ql)
- [org-appear](https://github.com/awth13/org-appear)
- [org-download](https://github.com/abo-abo/org-download)
- [ox-epub](https://github.com/ofosos/ox-epub)

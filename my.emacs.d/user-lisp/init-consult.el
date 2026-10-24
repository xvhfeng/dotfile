;;; -*- lexical-binding: t; -*-

;; 中文说明：rg 的自定义搜索参数使用 Transient 展示；仅加载其菜单框架，实际
;; ripgrep 搜索仍保持按需启动。
(require 'transient)

;; 中文说明：当前 Transient 0.7.2.2 未提供新版 rg.el 原生 `rg-menu' 所需的
;; `transient--set-layout' 内部接口。升级 Transient 会影响既有 Magit/工作台，
;; 因此在旧接口环境提供最小兼容层，跳过 rg.el 的英文原生菜单，统一使用下方
;; 中文 `my/rg-search-menu'；rg 的搜索、结果跳转与 wgrep 能力不受影响。
(unless (fboundp 'transient--set-layout)
  (defmacro rg-menu-wrap-transient-search (&rest _arguments)
    "旧版 Transient 下跳过 rg.el 原生菜单的搜索包装器。"
    nil)
  (defmacro rg-menu-wrap-transient-rerun (&rest _arguments)
    "旧版 Transient 下跳过 rg.el 原生菜单的重跑包装器。"
    nil)
  (defun rg-menu-transient-insert (&rest _arguments)
    "旧版 Transient 下忽略对 rg.el 原生菜单的扩展请求。"
    nil)
  (provide 'rg-menu))

;; 只向字节编译器声明 project.el API，不在这里提前加载 project.el。
;; 这样既消除编译警告，也避免与 straight 安装的 project 包争抢 feature。
(declare-function project-current "project" (&optional maybe-prompt dir))
(declare-function project-root "project" (project))
;; `consult-customize' 是第三方宏，不能在文件顶层通过 `eval-when-compile'
;; 提前 require Consult。Emacs 加载源码时也会执行 eager macro expansion；
;; 新机器或 Straight 重建后，顶层 require 会赶在下面的 :straight 安装声明
;; 之前运行，形成“必须先安装才能执行安装声明”的冷启动依赖环。
(defun my/consult-apply-customizations ()
  "Apply Consult preview settings after Consult has actually loaded.

Keep the macro calls quoted so loading or compiling this module never requires
Consult to exist beforehand.  `eval' expands them only from Consult's :config
phase, where `consult-customize' is guaranteed to be defined."
  (eval
   '(progn
      (consult-customize
       consult-ripgrep consult-git-grep consult-grep consult-man
       consult-bookmark consult-xref
       consult-source-bookmark consult-source-file-register
       consult-source-buffer consult-source-project-buffer
       consult-source-buffer-register
       :preview-key '(:debounce 1 any))
      (consult-customize
       consult-find
       :preview-key nil)
      (consult-customize
       consult-recent-file
       consult-source-recent-file consult-source-project-recent-file
       :preview-key nil))))

;; ============================================================================
;; 1. 定义以 `.projx` 为标志的项目根目录查找逻辑
;; ============================================================================

(defun my/find-projx-root (dir)
  "从 DIR 开始向上递归查找包含 .projx 文件的目录。"
  (let ((root (locate-dominating-file dir ".projx")))
    (when root
      ;; 返回符合 project.el 规范的 (transient . ROOT) 结构
      (cons 'transient (expand-file-name root)))))

;; 将 .projx 识别逻辑追加到 project.el 的项目查找钩子最前端 (优先于 .git)
(with-eval-after-load 'project
  (add-hook 'project-find-functions #'my/find-projx-root -10))

;; ============================================================================
;; 2. Consult + Ripgrep 自定义项目搜索配置
;; ============================================================================

;; 中文说明：rg.el 使用已经安装的 ripgrep 可执行文件，专门提供可保存为结果
;; Buffer 的搜索与替换工作流；它不启用默认 C-c s 绑定，统一交给本配置的
;; Which-Key 与个人工作台注册，避免键位重复或覆盖。
(use-package rg
  ;; 中文说明：明确指定上游仓库，避免当前 Straight 配方缓存缺少 rg 条目时
  ;; 只留下自动加载符号却没有实际安装包。
  :straight (:host github :repo "dajva/rg.el")
  :defer t
  :commands (rg-project rg-dwim-current-file)
  :init
  ;; 中文说明：与 Consult 项目搜索保持相同的常用排除规则；搜索隐藏文件时仍
  ;; 排除依赖、构建产物、Git 元数据与日志，降低项目搜索噪声。
  (setq rg-command-line-flags
        '("--hidden" "--glob=!node_modules/" "--glob=!.git/"
          "--glob=!target/" "--glob=!dist/" "--glob=!*.log")
        ;; 中文说明：rg.el 的 JSON 解析器将 ripgrep 的 UTF-8 字节偏移直接
        ;; 用作 Emacs 字符位置；中文行会触发范围错误并破坏跳转/替换。改用
        ;; rg.el 已支持的普通文本解析路径，保留结果定位与 wgrep 写回能力。
        rg-use-json-output nil
        ;; 中文说明：wgrep-rg 只能可靠解析标准“行:列:正文”格式；关闭 rg.el
        ;; 的空格对齐显示，避免把列号误作为正文而导致 C-c C-c 无法写回。
        rg-align-position-numbers nil))

(declare-function rg-project "rg" ())
(declare-function rg-dwim-current-file "rg" ())
(declare-function rg-run "rg" (pattern files dir &optional literal confirm flags))
(declare-function wgrep-rg-setup "wgrep-rg" ())
(declare-function wgrep-change-to-wgrep-mode "wgrep" ())
(declare-function wgrep-finish-edit "wgrep" ())
(declare-function wgrep-abort-changes "wgrep" ())

(defun my/rg--ensure-available ()
  "确认 rg.el 与 ripgrep 可用于执行搜索。"
  (unless (executable-find "rg")
    (user-error "找不到 ripgrep 可执行文件 rg"))
  (unless (or (featurep 'rg) (require 'rg nil t))
    (user-error "rg.el 尚未安装或加载")))

(defun my/rg-search-current-buffer ()
  "用 rg.el 搜索当前文件；结果 Buffer 可切换到 wgrep 进行替换。"
  (interactive)
  (unless buffer-file-name
    (user-error "当前 Buffer 未访问文件，无法使用 rg 搜索"))
  (my/rg--ensure-available)
  (call-interactively #'rg-dwim-current-file))

(defun my/rg-search-project ()
  "用 rg.el 搜索当前项目；项目根遵循 .projx 优先规则。"
  (interactive)
  (my/rg--ensure-available)
  (call-interactively #'rg-project))

(defun my/rg-edit-results ()
  "将当前 rg 结果 Buffer 变为 wgrep 可编辑替换模式。"
  (interactive)
  (unless (derived-mode-p 'rg-mode)
    (user-error "请先在 rg 搜索结果 Buffer 中执行此操作"))
  (unless (require 'wgrep-rg nil t)
    (user-error "rg.el 的 wgrep 替换支持尚未安装或加载"))
  ;; 中文说明：必须使用 rg.el 自带的 wgrep-rg 解析器；通用 wgrep-setup 会
  ;; 按 grep 输出格式重置解析规则，导致 rg 的分组结果无法可靠写回原文件。
  (wgrep-rg-setup)
  (wgrep-change-to-wgrep-mode)
  ;; 中文说明：wgrep 进入编辑状态后再次明确安装保存/放弃键，确保 rg 结果
  ;; Buffer 的局部 map 优先处理它们，不被全局 C-c 前缀或其他 minor mode 抢占。
  (define-key (current-local-map) (kbd "C-c C-c") #'wgrep-finish-edit)
  (define-key (current-local-map) (kbd "C-c C-k") #'wgrep-abort-changes))

(defun my/rg--menu-flags ()
  "返回 rg Transient 菜单中当前选中的附加命令行参数。"
  (transient-args 'my/rg-search-menu))

(defun my/rg--call-with-menu-flags (command)
  "以 rg 菜单参数交互调用 COMMAND。"
  (let ((rg-command-line-flags
         (append rg-command-line-flags (my/rg--menu-flags))))
    (call-interactively command)))

(defun my/rg-menu-search-current-buffer ()
  "使用 rg 菜单参数搜索当前 Buffer。"
  (interactive)
  (my/rg--call-with-menu-flags #'my/rg-search-current-buffer))

(defun my/rg-menu-search-project ()
  "使用 rg 菜单参数搜索当前项目。"
  (interactive)
  (my/rg--call-with-menu-flags #'my/rg-search-project))

(defun my/rg--matching-files (search directory files flags)
  "返回 DIRECTORY 中被 rg 字面量 SEARCH 命中的 FILES 列表。"
  (let* ((default-directory (file-name-as-directory directory))
         (arguments (append '("--files-with-matches" "--null" "--fixed-strings")
                            rg-command-line-flags flags
                            (list "-e" search)
                            ;; 中文说明：项目搜索的 everything 表示搜索目录本身，
                            ;; 不能把单词 everything 作为路径传给 ripgrep。
                            (unless (equal files "everything")
                              (list "--" files))))
         (output (with-temp-buffer
                   (let ((exit-code
                          (apply #'process-file (executable-find "rg") nil t nil
                                 arguments)))
                     (unless (memq exit-code '(0 1))
                       (user-error "rg 直接替换搜索失败：%s" (buffer-string)))
                     (buffer-string)))))
    (mapcar (lambda (file) (expand-file-name file directory))
            (split-string output "\0" t))))

(defun my/rg--replace-literal-in-file (file search replacement)
  "在 FILE 中替换所有字面量 SEARCH，并返回替换数量。"
  (let ((buffer (find-file-noselect file))
        (count 0))
    (with-current-buffer buffer
      (save-restriction
        (widen)
        (save-excursion
          (goto-char (point-min))
          (let ((case-fold-search nil))
            (while (search-forward search nil t)
              (replace-match replacement t t)
              (setq count (1+ count))))))
      ;; 中文说明：通过访问文件的 Buffer 保存，已打开文件会同步更新，避免直接
      ;; 写磁盘造成用户正在编辑的 Buffer 与磁盘版本脱节。
      (when (> count 0)
        (save-buffer)))
    count))

(defun my/rg--run-direct-replace (search replacement files directory flags)
  "在 DIRECTORY 中用 rg 找到 FILES 后直接替换字面量文本并保存。"
  (my/rg--ensure-available)
  (let ((matches (my/rg--matching-files search directory files flags)))
    (if (null matches)
        (message "rg 未找到可直接替换的文本：%s" search)
      (when (yes-or-no-p
             (format "rg 将在 %d 个文件中把 %S 直接替换为 %S，继续？ "
                     (length matches) search replacement))
        (let ((count 0))
          (dolist (file matches)
            (setq count (+ count
                           (my/rg--replace-literal-in-file file search replacement))))
          (message "rg 直接替换完成：%d 个文件，%d 处文本" (length matches) count))))))

(defun my/rg--read-direct-replace-values ()
  "读取 rg 字面量直接替换所需的查找与替换文本。"
  (let* ((default (thing-at-point 'symbol t))
         (search (read-string "直接替换：查找的字面量文本: " default))
         (replacement (read-string "直接替换为: ")))
    (when (string-empty-p search)
      (user-error "查找文本不能为空"))
    (list search replacement)))

(defun my/rg-direct-replace-current-buffer ()
  "在当前文件中用 rg 查找并直接替换字面量文本。"
  (interactive)
  (unless buffer-file-name
    (user-error "当前 Buffer 未访问文件，无法直接替换"))
  (pcase-let ((`(,search ,replacement) (my/rg--read-direct-replace-values)))
    (my/rg--run-direct-replace
     search replacement (file-name-nondirectory buffer-file-name)
     (file-name-directory buffer-file-name) (my/rg--menu-flags))))

(defun my/rg-direct-replace-project ()
  "在当前项目文件中用 rg 查找并直接替换字面量文本。"
  (interactive)
  (my/rg--ensure-available)
  (unless-let ((project (project-current nil)))
    (user-error "当前目录不属于项目，无法进行项目直接替换"))
  (pcase-let ((`(,search ,replacement) (my/rg--read-direct-replace-values)))
    (my/rg--run-direct-replace
     search replacement "everything" (project-root project) (my/rg--menu-flags))))

(transient-define-prefix my/rg-search-menu ()
  "打开 rg 的搜索、文件过滤与直接替换菜单。"
  [["   常用搜索参数"
    ("g" "自定义 Glob（如 *.c 或 !vendor/**）" "--glob=")
    ("t" "仅文件类型（如 c）" "--type=")
    ("T" "排除文件类型" "--type-not=")
    ("i" "忽略大小写" "--ignore-case")
    ("S" "严格区分大小写" "--case-sensitive")
    ("n" "忽略 .gitignore 等规则" "--no-ignore")]
   ["   rg 搜索"
    ("b" "搜索当前 Buffer" my/rg-menu-search-current-buffer)
    ("p" "搜索项目文件" my/rg-menu-search-project)]
   ["   rg 直接替换（字面量）"
    ("B" "直接替换当前 Buffer" my/rg-direct-replace-current-buffer)
    ("P" "直接替换项目文件" my/rg-direct-replace-project)]])

(defun my/consult-edit-exported-results ()
  "将 Embark 导出的 Consult grep 结果变为可编辑替换模式。"
  (interactive)
  (unless (derived-mode-p 'grep-mode)
    (user-error "请先从 Consult 结果按 M-. E 导出到 *grep* Buffer"))
  (unless (require 'wgrep nil t)
    (user-error "wgrep 尚未安装或加载"))
  ;; 中文说明：Consult 经 Embark 导出的是标准 grep-mode，使用通用 wgrep
  ;; 解析器即可；这与 rg-mode 必须使用 wgrep-rg 解析器的路径保持分离。
  (wgrep-setup)
  (wgrep-change-to-wgrep-mode))

(use-package consult
  :straight t
  :defer t
  :init
  ;; 用 Consult 替换原生 Register 预览；只安装一次 advice。
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)
  (advice-add #'register-preview :override #'consult-register-window)

  :custom
  ;; 轻量候选仍即时预览；昂贵的文件/Buffer 预览在 :config 中单独防抖。
  (consult-preview-key 'any)

  :config
  ;; 自定义 ripgrep 参数：忽略日志、node_modules 等
  (setq consult-ripgrep-args
        "rg --null --line-buffered --color=never --max-columns=1000 --path-separator / --smart-case --no-heading --line-number --hidden -g !node_modules/ -g !.git/ -g !target/ -g !dist/ -g !*.log")

  ;; 确保 Consult 在找不到项目时，优雅兜底到当前 Buffer 所在文件夹
;; 使用官方推荐的属性设置项目根路径查找逻辑
  (setq consult-project-function
        (lambda (&optional dir)
          (when-let ((proj (project-current nil dir)))
            (project-root proj))))

  ;; 搜索、书签和 Buffer 候选可能很多，快速移动时延迟预览，避免大项目中
  ;; 无意义的磁盘读取和窗口重绘。
  ;; `consult-recent-file' 的预览会打开候选文件。候选移动的优先级高于
  ;; 预览，因此完全关闭该命令的自动预览，避免 C-n/C-p 触发磁盘读取。
  (my/consult-apply-customizations))

;; 不使用 use-package 的 :general 关键字；等 General 可用后再绑定。
(with-eval-after-load 'general
  (general-define-key
   "C-c p s" '("项目搜索" . consult-ripgrep)
   "M-s r" '("项目 Ripgrep 搜索" . consult-ripgrep)
   "M-s l" '("当前文件搜索" . consult-line)
   "M-s f" '("查找文件" . consult-find)
   "C-c ! l" '("诊断列表" . consult-flymake)))

;; 中文说明：搜索与替换直接平铺在 C-c s 下，不另建 rg 子前缀。用户可通过
;; Which-Key 一次看到 Consult 的即时搜索，以及 rg 的当前文件/项目替换流程。
(with-eval-after-load 'general
  (my-leader-def
    "s l" '("Consult：当前 Buffer 搜索" . consult-line)
    "s p" '("Consult：项目搜索" . consult-ripgrep)
    "s E" '("Consult：编辑导出结果并写回" . my/consult-edit-exported-results)
    ;; 中文说明：小写 s b 已由 Consult 作为书签入口使用；用大写 B 保留现有
    ;; 书签功能，同时让 rg 当前 Buffer 搜索拥有稳定且可发现的独立键位。
    "s B" '("rg：当前 Buffer 搜索/替换" . my/rg-search-current-buffer)
    "s r" '("rg：项目文件搜索/替换" . my/rg-search-project)
    "s m" '("rg：搜索、过滤与直接替换" . my/rg-search-menu)
    "s e" '("rg：编辑结果并写回" . my/rg-edit-results)))



;; 挂载到 General.el 体系下的诊断菜单 (C-c c d ...)
(with-eval-after-load 'general
  (my-leader-def
    "c d l" '("搜索诊断" . consult-flymake)))


;; ============================================================================
;; Wgrep: 搜索结果导出后的批量重构
;; Embark 的初始化与按键统一由 init-completion.el 管理。
;; ============================================================================

(use-package wgrep
  :straight t
  :custom
  (wgrep-auto-save-buffer t)                 ; C-c C-c 保存时自动写入磁盘文件
  (wgrep-change-readonly-file t))

(provide 'init-consult)


;; 替换三步法流程：
;; 搜索： 执行 M-x consult-ripgrep（或 consult-grep），输入你想查找的文本。
;; 导出： 在 Minibuffer 结果列表中，按下 M-. E（即调用 embark-act 然后按 E 执行 embark-export），这会将搜索结果导出到一个 *grep* 缓冲区。
;; 可编辑替换：
;; 在 *grep* 缓冲区中，按下 C-c C-p（进入 wgrep-change-to-wgrep-mode 模式）。
;; 此时该缓冲区变为可编辑状态！你可以直接用 M-% (query-replace) 或 C-M-% (query-replace-regexp) 在这个 Buffer 中批量替换。
;; 保存改动： 替换完成后，按下 C-c C-c，wgrep 会自动将修改写入对应的所有物理磁盘文件；如果想放弃，按 C-c C-k。

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 含 `.projx' 的目录会被识别为项目根目录；项目搜索忽略 .git/node_modules/target/dist/log。
;; - `C-c p s' 或 `M-s r' 搜索项目，`M-s l' 搜索当前 Buffer，`M-s f' 查找文件。
;; - `C-c s l/p' 是 Consult 的当前 Buffer/项目搜索；`C-c s B/r/m/e' 分别是
;;   rg 当前文件搜索、rg 项目搜索、中文过滤/直接替换菜单与将 rg 结果切为可编辑替换模式。
;; - `C-c ! l' 或 `C-c c d l' 汇总 Flymake 诊断；`C-c E' 导出当前候选结果。
;; - 批量替换流程：Consult 搜索 -> `M-. E' 导出 -> `C-c C-p' 进入 Wgrep；rg
;;   搜索后则在结果 Buffer 按 `C-c s e'，编辑完成按 `C-c C-c' 写回文件。
;; - 在 Wgrep 中编辑后按 `C-c C-c' 写回文件，按 `C-c C-k' 放弃全部修改。
;; - rg 搜索后，在结果 Buffer 使用 `re' / `C-c s e' 进入可编辑模式，编辑完成
;;   按 `C-c C-c' 写回文件，按 `C-c C-k' 放弃。`C-c s m' 菜单的 B/P 提供
;;   当前文件/项目的字面量直接替换，确认后立即写回匹配文件。

;;; -*- lexical-binding: t; -*-

;; 中文说明：rg 的自定义搜索参数使用 Transient 展示；仅加载其菜单框架，实际
;; ripgrep 搜索仍保持按需启动。
(require 'transient)

;; M-s 改为本配置的四列搜索菜单；移除 Emacs 原生 search-map 的 hi-lock 前缀，
;; 避免高亮匹配功能继续出现在搜索入口中。
(define-key search-map (kbd "h") nil)
(defconst my/search-map-extended-search-map
  (lookup-key search-map (kbd "ESC"))
  "Emacs 原生 search-map 中原先位于 ESC 下的扩展搜索子 map。")
(define-key search-map (kbd "ESC") nil)
(define-key search-map (kbd "e") my/search-map-extended-search-map)

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

;; Projectile 的项目替换是 `projectile-replace' 命令，不是独立包。
;; 仅安装命令而不启用 projectile-mode，避免接管现有 project.el 的项目发现。
(use-package projectile
  :straight (:host github :repo "bbatsov/projectile")
  :commands (projectile-replace projectile-replace-regexp)
  :init
  (setq projectile-known-projects-file (my/runtime-file "projectile/known-projects.eld")
        projectile-cache-file (my/runtime-file "projectile/cache.eld"))
  (make-directory (my/runtime-file "projectile/") t)
  :config
  ;; 与 project.el 一样先识别 .projx，再使用 Projectile 自带的 Git 等规则。
  (defun my/projectile-projx-root (dir)
    "优先返回 DIR 上层由 .projx 标记的项目根。"
    (when-let ((root (locate-dominating-file dir ".projx")))
      (file-name-as-directory (expand-file-name root))))
  (add-to-list 'projectile-project-root-functions #'my/projectile-projx-root))

;; 普通编辑时保留 M-% 的原生替换；增量搜索进行中用 Anzu 接续替换。
(use-package anzu
  :straight (:host github :repo "emacsorphanage/anzu")
  :demand t
  :custom
  ;; 光标处范围替换只作用于当前函数，避免无询问命令改动整个缓冲区。
  (anzu-replace-at-cursor-thing 'defun)
  :config
  (global-anzu-mode 1)
  ;; 增量搜索用黄色标记当前命中、亮青色标记其他命中，便于在深色背景上区分。
  (setq isearch-lazy-highlight t)
  (custom-set-faces
   '(isearch ((t (:background "#e0af68" :foreground "#1f2335" :weight bold))))
   '(lazy-highlight ((t (:background "#7dcfff" :foreground "#1f2335" :weight bold))))
   '(anzu-mode-line ((t (:foreground "#7aa2f7" :weight bold))))
   '(anzu-mode-line-no-match ((t (:foreground "#f7768e" :weight bold))))
   '(anzu-replace-highlight ((t (:background "#e0af68" :foreground "#1f2335" :weight bold))))
   '(anzu-replace-to ((t (:foreground "#9ece6a" :weight bold))))
   '(anzu-match-1 ((t (:background "#7aa2f7" :foreground "#1f2335"))))
   '(anzu-match-2 ((t (:background "#9ece6a" :foreground "#1f2335"))))
   '(anzu-match-3 ((t (:background "#bb9af7" :foreground "#1f2335"))))))

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
    ("g" "自定义文件匹配〔rg〕" "--glob=")
    ("t" "仅文件类型〔rg〕" "--type=")
    ("T" "排除文件类型〔rg〕" "--type-not=")
    ("i" "忽略大小写〔rg〕" "--ignore-case")
    ("S" "严格区分大小写〔rg〕" "--case-sensitive")
    ("n" "包含被忽略文件〔rg〕" "--no-ignore")]
   ["   rg 搜索"
    ("b" "搜索当前缓冲区〔rg〕" my/rg-menu-search-current-buffer)
    ("p" "搜索项目文件〔rg〕" my/rg-menu-search-project)]
   ["   rg 直接替换（字面量）"
    ("B" "直接替换当前文件〔rg〕" my/rg-direct-replace-current-buffer)
    ("P" "直接替换项目文件〔rg〕" my/rg-direct-replace-project)]])

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

(defun my/consult-exported-results-enable-edit ()
  "将当前导出结果切换到 Wgrep 或 Wdired 编辑模式。"
  (interactive)
  (cond
   ((derived-mode-p 'grep-mode)
    (my/consult-edit-exported-results))
   ((derived-mode-p 'dired-mode)
    (require 'wdired)
    (wdired-change-to-wdired-mode))
   ((derived-mode-p 'occur-mode)
    (my/consult-exported-results--snapshot-occur-sources)
    (occur-edit-mode))
   (t
    (user-error "当前导出结果不支持直接编辑"))))

(defvar-local my/consult-exported-results-p nil
  "Non-nil when the current buffer was created by Embark Export/Collect.")
(put 'my/consult-exported-results-p 'permanent-local t)

(define-minor-mode my/consult-exported-results-menu-mode
  "Keep the exported-results operation menu reachable across mode changes."
  :init-value nil
  :lighter nil)
(put 'my/consult-exported-results-menu-mode 'permanent-local t)

(defvar my/consult-exported-results-menu-emulation-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-t") #'my/consult-exported-results-toggle-menu)
    map)
  "High-priority C-t keymap used only by Embark Export/Collect buffers.")

(defvar my/consult-exported-results-menu-emulation-alist
  `((my/consult-exported-results-menu-mode
     . ,my/consult-exported-results-menu-emulation-map))
  "Emulation map alist that preserves the Export menu key across modes.")

(add-to-list 'emulation-mode-map-alists
             'my/consult-exported-results-menu-emulation-alist)

(defun my/consult-exported-results-buffer-p ()
  "Return non-nil in an Embark Export or Collect result buffer."
  (or my/consult-exported-results-p
      (derived-mode-p 'embark-collect-mode)
      (string-prefix-p "*Embark Export:" (buffer-name))))

(defun my/consult-exported-results-grep-p ()
  "Return non-nil when current exported results support Wgrep operations."
  (derived-mode-p 'grep-mode))

(defun my/consult-exported-results-occur-p ()
  "Return non-nil when current exported results are an Occur buffer."
  (derived-mode-p 'occur-mode))

(defvar-local my/consult-exported-results-occur-snapshots nil
  "Snapshots of source buffers before entering Occur Edit mode.")
(put 'my/consult-exported-results-occur-snapshots 'permanent-local t)

(defun my/consult-exported-results--occur-markers (value)
  "Collect markers recursively contained in an Occur target VALUE."
  (cond
   ((markerp value) (list value))
   ((consp value)
    (append (my/consult-exported-results--occur-markers (car value))
            (my/consult-exported-results--occur-markers (cdr value))))))

(defun my/consult-exported-results--snapshot-occur-sources ()
  "Snapshot source buffers referenced by the current Occur buffer."
  (let (buffers)
    (save-excursion
      (goto-char (point-min))
      (while (< (point) (point-max))
        (dolist (marker (my/consult-exported-results--occur-markers
                         (get-text-property (point) 'occur-target)))
          (when-let ((buffer (marker-buffer marker)))
            (cl-pushnew buffer buffers)))
        (goto-char (next-single-property-change
                    (point) 'occur-target nil (point-max)))))
    (setq-local my/consult-exported-results-occur-snapshots
                (mapcar (lambda (buffer)
                          (with-current-buffer buffer
                            (list buffer (buffer-string) (buffer-modified-p))))
                        buffers))))

(defun my/consult-exported-results--restore-occur-sources ()
  "Restore source buffers from the Occur Edit snapshot."
  (dolist (snapshot my/consult-exported-results-occur-snapshots)
    (pcase-let ((`(,buffer ,content ,modified) snapshot))
      (when (buffer-live-p buffer)
        (with-current-buffer buffer
          (let ((inhibit-read-only t))
            (erase-buffer)
            (insert content)
            (set-buffer-modified-p modified))))))
  (setq-local my/consult-exported-results-occur-snapshots nil))

(defun my/consult-exported-results-setup-menu ()
  "Install the exported-results menu toggle in the newly created buffer."
  (setq-local my/consult-exported-results-p t)
  (my/consult-exported-results-menu-mode 1))

(defun my/consult-exported-results-restore-toggle ()
  "Restore the local C-t menu key after an exported result changes edit mode."
  ;; Occur Edit/Wdired 可能清除普通局部变量；名称兜底能恢复永久 minor mode。
  (when (my/consult-exported-results-buffer-p)
    (setq-local my/consult-exported-results-p t)
    (my/consult-exported-results-menu-mode 1)))

(defun my/consult-exported-results-write ()
  "写回当前 Consult 导出结果中的 Wgrep 修改。"
  (interactive)
  (cond
   ((bound-and-true-p wgrep-mode)
    (wgrep-finish-edit))
   ((bound-and-true-p wdired-mode)
    (wdired-finish-edit))
   ((derived-mode-p 'occur-edit-mode)
    (occur-cease-edit)
    (dolist (snapshot my/consult-exported-results-occur-snapshots)
      (when-let ((buffer (car snapshot)))
        (with-current-buffer buffer
          (when (and buffer-file-name (buffer-modified-p))
            (save-buffer)))))
    (setq-local my/consult-exported-results-occur-snapshots nil))
   (t
    (user-error "当前结果尚未进入编辑模式；请先按 e"))))

(defun my/consult-exported-results-abort ()
  "放弃当前 Consult 导出结果中的 Wgrep 修改。"
  (interactive)
  (cond
   ((bound-and-true-p wgrep-mode)
    (wgrep-abort-changes))
   ((bound-and-true-p wdired-mode)
    (wdired-abort-changes))
   ((derived-mode-p 'occur-edit-mode)
    ;; Occur 编辑即时同步来源 Buffer，故由本配置的快照恢复。
    (my/consult-exported-results--restore-occur-sources)
    (occur-cease-edit)
    (message "已恢复 Occur 编辑前的来源 Buffer 内容"))
   (t
    (message "当前结果没有待放弃的编辑修改"))))

(defun my/consult-exported-results-rerun ()
  "重新执行当前 Consult 导出结果的来源搜索。"
  (interactive)
  (cond
   ((fboundp 'embark-rerun-collect-or-export)
    (call-interactively #'embark-rerun-collect-or-export))
   ((fboundp 'recompile)
    (recompile))
   (t
    (revert-buffer))))

(defun my/consult-exported-results-query-replace ()
  "在当前 Consult 导出结果 Buffer 中执行普通逐一替换。"
  (interactive)
  (unless (derived-mode-p 'grep-mode)
    (user-error "文本替换仅适用于 grep 类型的导出结果"))
  (call-interactively #'query-replace))

(defun my/consult-exported-results-query-replace-regexp ()
  "在当前 Consult 导出结果 Buffer 中执行正则逐一替换。"
  (interactive)
  (unless (derived-mode-p 'grep-mode)
    (user-error "正则替换仅适用于 grep 类型的导出结果"))
  (call-interactively #'query-replace-regexp))

(defun my/consult-exported-results-close ()
  "放弃未确认编辑、退出菜单并关闭当前 Embark Export Buffer。"
  (interactive)
  (let ((buffer (current-buffer)))
    (when (or (bound-and-true-p wgrep-mode)
              (bound-and-true-p wdired-mode)
              (derived-mode-p 'occur-edit-mode))
      (my/consult-exported-results-abort))
    (when (transient-active-prefix '(my/consult-exported-results-menu))
      (transient-quit-all))
    (when (buffer-live-p buffer)
      (kill-buffer buffer))))

(transient-define-prefix my/consult-exported-results-menu ()
  "操作由 Consult 导出到 grep Buffer 的搜索结果。"
  [["   搜索与定位"
    ("r" "重新执行来源搜索" my/consult-exported-results-rerun)]
   ["   写回与替换"
    ("e" "开启编辑" my/consult-exported-results-enable-edit)
    ("w" "写回修改" my/consult-exported-results-write)
    ("a" "放弃修改" my/consult-exported-results-abort)
    ("s" "逐一替换（grep）" my/consult-exported-results-query-replace)
    ("x" "正则替换（grep）" my/consult-exported-results-query-replace-regexp)
    ("q" "退出并关闭结果" my/consult-exported-results-close)]])

(defun my/consult-exported-results-toggle-menu ()
  "切换当前 Consult 导出结果 Buffer 的操作菜单。"
  (interactive)
  (if (transient-active-prefix '(my/consult-exported-results-menu))
      (transient-quit-all)
    (unless (my/consult-exported-results-buffer-p)
      (user-error "此菜单仅用于 Embark 导出或 Collect 结果 Buffer"))
    (my/consult-exported-results-menu)))

(with-eval-after-load 'embark
  ;; Embark Export 的文件结果是 Dired、Buffer 结果是 Ibuffer，Consult 搜索
  ;; 结果才可能是 grep/occur；统一在导出钩子中设置局部 C-t。
  (add-hook 'embark-after-export-hook #'my/consult-exported-results-setup-menu)
  (add-hook 'embark-collect-mode-hook #'my/consult-exported-results-setup-menu))

;; Occur、Wdired 与 Wgrep 进入编辑模式时会替换局部 map；在模式切换结束后
;; 恢复 Export Buffer 的 C-t 菜单开关。
(dolist (hook '(occur-edit-mode-hook wdired-mode-hook wgrep-mode-hook))
  (add-hook hook #'my/consult-exported-results-restore-toggle))

;; Consult 将不同搜索命令的输入分别保存；声明变量使字节编译明确这些历史由
;; Consult 在运行时维护，而不要求启动阶段提前加载完整插件。
(defvar consult--line-history)
(defvar consult--grep-history)

(defun my/consult--select-search-history (history prompt)
  "从 HISTORY 中选择一条搜索词，PROMPT 用于说明历史类别。"
  (let ((items (delete-dups (seq-filter #'stringp (copy-sequence history)))))
    (unless items
      (user-error "%s暂无搜索历史" prompt))
    (completing-read (format "%s: " prompt) items nil t)))

(defun my/consult-line-history ()
  "选择当前 Buffer 的 Consult 搜索历史并重新打开搜索。"
  (interactive)
  (require 'consult)
  (consult-line
   (my/consult--select-search-history consult--line-history
                                      "当前 Buffer 搜索历史")))

(defun my/consult-ripgrep-history ()
  "选择项目 Consult 搜索历史并重新打开项目搜索。"
  (interactive)
  (require 'consult)
  (consult-ripgrep
   nil
   (my/consult--select-search-history consult--grep-history
                                      "项目搜索历史")))

(transient-define-prefix my/consult-search-history-menu ()
  "查看并恢复最近使用过的 Consult 搜索词。"
  [["   搜索历史"
    ("l" "当前缓冲区搜索词〔Consult〕" my/consult-line-history)
    ("p" "项目搜索词〔Consult〕" my/consult-ripgrep-history)]])

(transient-define-prefix my/anzu-menu ()
  "打开 Anzu 命中计数与替换菜单。"
  [["   搜索计数与替换"
    ("t" "切换全局命中计数〔Anzu〕" global-anzu-mode)
    ("q" "逐一替换〔Anzu〕" anzu-query-replace)
    ("r" "正则逐一替换〔Anzu〕" anzu-query-replace-regexp)
    ("s" "替换光标处符号〔Anzu〕" anzu-query-replace-at-cursor)
    ("d" "当前函数内逐一替换光标处符号〔Anzu〕" anzu-query-replace-at-cursor-thing)
    ("x" "当前函数内直接替换光标处符号〔Anzu〕" anzu-replace-at-cursor-thing)]
   ["   增量搜索中：M-% 逐一替换，C-M-% 正则替换"
    ("DEL" "返回上级菜单" transient-quit-one)
    ("C-d" "关闭菜单" transient-quit-all)]])

(defun my/anzu-buffer-search ()
  "启动带 Anzu 全 Buffer 命中计数的普通增量搜索。"
  (interactive)
  (unless global-anzu-mode
    (global-anzu-mode 1))
  (call-interactively #'isearch-forward))

(defun my/anzu-buffer-regexp-search ()
  "启动带 Anzu 全 Buffer 命中计数的正则增量搜索。"
  (interactive)
  (unless global-anzu-mode
    (global-anzu-mode 1))
  (call-interactively #'isearch-forward-regexp))

(transient-define-prefix my/m-s-search-menu ()
  "打开三列平铺的搜索与替换菜单。"
  :column-widths '(21 21 21)
  [["   Consult 搜索"
    ("c" "当前搜索" consult-line)
    ("p" "项目搜索" consult-ripgrep)
    ("f" "文件搜索" consult-find)
    ("b" "切换 Buffer" consult-buffer)
    ("y" "搜索历史" my/consult-line-history)]
   ["   Anzu 搜索与替换"
    ("g" "全 Buffer 匹配" my/anzu-buffer-search)
    ("h" "全 Buffer 正则匹配" my/anzu-buffer-regexp-search)
    ("t" "计数开关" global-anzu-mode)
    ("q" "逐一替换" anzu-query-replace)
    ("r" "正则替换" anzu-query-replace-regexp)
    ("d" "替换光标符号" anzu-query-replace-at-cursor)
    ("x" "函数内替换符号" anzu-replace-at-cursor-thing)]
   ["   Emacs 原生搜索与替换"
    ("i" "向前搜索" isearch-forward)
    ("j" "向后搜索" isearch-backward)
    ("v" "正则前搜" isearch-forward-regexp)
    ("z" "正则后搜" isearch-backward-regexp)
    ("o" "列出匹配行" occur)
    ("s" "正则替换" query-replace-regexp)
    ("l" "逐一替换" query-replace)]])

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

(with-eval-after-load 'consult
  ;; 中文说明：Consult 异步输入 map 会覆盖部分 Minibuffer 默认完成键；明确保留
  ;; M-p/M-n 的历史浏览，确保重新打开搜索后可逐条恢复刚刚的搜索词。
  (keymap-set consult-async-map "M-p" #'previous-history-element)
  (keymap-set consult-async-map "M-n" #'next-history-element))

;; 不使用 use-package 的 :general 关键字；等 General 可用后再绑定。
(with-eval-after-load 'general
  (general-define-key
   "C-c p s" '("项目搜索" . consult-ripgrep)
   "M-s" '("搜索与替换" . my/m-s-search-menu)
   "C-c ! l" '("诊断列表" . consult-flymake)))

;; isearch 自带 M-% / C-M-% 本来分别进入普通/正则逐一替换；仅在 isearch
;; 过程中换成 Anzu 版本，保留普通编辑状态的原生 M-% / C-M-%。
(with-eval-after-load 'general
  (general-define-key :keymaps 'isearch-mode-map
    "M-%" '("增量搜索后逐一替换〔Anzu〕" . anzu-isearch-query-replace)
    "C-M-%" '("增量搜索后正则逐一替换〔Anzu〕" . anzu-isearch-query-replace-regexp)
    ;; 终端无法稳定发送 C-M-% 时，也可从当前 isearch 的 M-s 菜单进入。
    "M-s a" '("增量搜索后逐一替换〔Anzu〕" . anzu-isearch-query-replace)
    "M-s A" '("增量搜索后正则逐一替换〔Anzu〕" . anzu-isearch-query-replace-regexp)))

;; M-s 使用自定义四列菜单；保留 search-map 其余原生键并移除高亮匹配前缀。
(with-eval-after-load 'which-key
  (which-key-add-keymap-based-replacements
    global-map "M-s" "搜索与替换菜单")
  (which-key-add-keymap-based-replacements
    isearch-mode-map "M-s" "增量搜索选项")
  (which-key-add-keymap-based-replacements
    search-map
    "." "搜索光标处符号〔i-search〕"
    "_" "向前搜索符号〔i-search〕"
    "w" "向前搜索单词〔i-search〕"
    "o" "列出匹配行〔Emacs〕"
    "e" "扩展搜索"
    "e ." "搜索光标处内容〔i-search〕"
    "e w" "网页搜索词〔EWW〕"))

;; 中文说明：搜索与替换直接平铺在 C-c s 下，不另建 rg 子前缀。用户可通过
;; Which-Key 一次看到 Consult 的即时搜索，以及 rg 的当前文件/项目替换流程。
(with-eval-after-load 'general
  (my-leader-def
    ;; s/s 与 s/i 已分别用于 Consult 搜索、符号列表；沿用原键位。
    "s /" '("向前增量搜索〔i-search〕" . isearch-forward)
    "s I" '("向后增量搜索〔i-search〕" . isearch-backward)
    "s q" '("逐一替换〔Emacs〕" . query-replace)
    "s Q" '("正则逐一替换〔Emacs〕" . query-replace-regexp)
    "s P" '("项目逐一替换〔Projectile〕" . projectile-replace)
    "s a" '("替换与计数菜单〔Anzu〕" . my/anzu-menu)
    "s A" '("切换命中计数〔Anzu〕" . global-anzu-mode)
    "s l" '("当前缓冲区搜索〔Consult〕" . consult-line)
    "s p" '("项目搜索〔Consult〕" . consult-ripgrep)
    "s E" '("编辑导出结果并写回〔Consult〕" . my/consult-edit-exported-results)
    ;; 中文说明：小写 s b 已由 Consult 作为书签入口使用；用大写 B 保留现有
    ;; 书签功能，同时让 rg 当前 Buffer 搜索拥有稳定且可发现的独立键位。
    "s B" '("当前缓冲区搜索/替换〔rg〕" . my/rg-search-current-buffer)
    "s r" '("项目文件搜索/替换〔rg〕" . my/rg-search-project)
    "s m" '("搜索、过滤与直接替换〔rg〕" . my/rg-search-menu)
    "s e" '("编辑结果并写回〔rg〕" . my/rg-edit-results)))



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
;; - `C-c p s' 或 `M-s r' 搜索项目，`M-s l' 搜索当前 Buffer，`M-s f' 查找文件；
;;   `M-s H' 打开 Consult 搜索历史，可按 l/p 恢复当前 Buffer/项目的搜索词。
;; - `C-c s l/p' 是 Consult 的当前 Buffer/项目搜索；`C-c s B/r/m/e' 分别是
;;   rg 当前文件搜索、rg 项目搜索、中文过滤/直接替换菜单与将 rg 结果切为可编辑替换模式。
;; - `C-c ! l' 或 `C-c c d l' 汇总 Flymake 诊断；`C-c E' 导出当前候选结果。
;; - 批量替换流程：Consult 搜索 -> `M-. E' 导出 -> `C-c C-p' 进入 Wgrep；rg
;;   搜索后则在结果 Buffer 按 `C-c s e'，编辑完成按 `C-c C-c' 写回文件。
;; - 在 Wgrep 中编辑后按 `C-c C-c' 写回文件，按 `C-c C-k' 放弃全部修改。
;; - rg 搜索后，在结果 Buffer 使用 `re' / `C-c s e' 进入可编辑模式，编辑完成
;;   按 `C-c C-c' 写回文件，按 `C-c C-k' 放弃。`C-c s m' 菜单的 B/P 提供
;;   当前文件/项目的字面量直接替换，确认后立即写回匹配文件。

;;; -*- lexical-binding: t -*-

;;; 中文导读：补全与代码智能模块。Icomplete 增强 minibuffer，Corfu 弹出正文补全，
;;; completion-preview 显示内联预览，Dabbrev 从缓冲区扩词，Yasnippet 展开模板，
;;; Eglot 连接语言服务器。F2 重命名；F12/S-F12/C-F12/C-S-F12 分别找定义、引用、
;;; 实现、类型定义；C-. 快速修复；C-x C-r 打开最近文件。补全预览用 C-n/C-p
;;; 换候选；Corfu 中 RET 完成、ESC 关闭、S-SPC 插分隔符，M-p 切换文档窗口，
;;; M-1/M-2 滚动文档。
;;; Dabbrev - 原生动态缩写补全设置
(use-package dabbrev
  :ensure nil
  :custom
  (dabbrev-case-replace nil)                  ; 替换时不强制转换大小写
  (dabbrev-downcase-means-case-replace nil)
  (dabbrev-case-distinction nil))             ; 补全时忽略大小写差异

;;; Eglot - 轻量级 LSP 客户端
(use-package eglot
  :ensure nil
  :bind
  ("<f2>" . eglot-rename)                      ; F2: 重命名符号
  ("<f12>" . xref-find-definitions)            ; F12: 跳转到定义
  ("S-<f12>" . xref-find-references)           ; Shift+F12: 查找所有引用
  ("C-<f12>" . eglot-find-implementation)      ; Ctrl+F12: 查找接口实现
  ("C-S-<f12>" . eglot-find-typeDefinition)    ; Ctrl+Shift+F12: 跳转到类型定义
  ("C-." . eglot-code-action-quickfix)         ; Ctrl+. : 快速修复 (Quickfix)
  :custom
  (eglot-autoshutdown t)                       ; 最后一个相关 Buffer 关闭时自动关闭 LSP Server
  (eglot-code-action-indications '(left-fringe)) ; 将 Code Action 提示灯显示在左侧 Margin 边缘
  (eglot-events-buffer-config '(:size 0 :format 'short)) ; 禁用/最小化 JSONRPC 事件日志 Buffer
  (eglot-documentation-renderer 'markdown-ts-view-mode)  ; 使用 tree-sitter markdown 渲染 Hover 文档
  (eglot-ignored-server-capabilities          ; 禁用高开销或不必要的 LSP 功能以提升性能
   '(:inlayHintProvider
     :documentHighlightProvider
     :foldingRangeProvider))
  :config
  ;; 自定义边缘 (fringe) 提示小图标 (16x16 矩阵)
  (define-fringe-bitmap 'eglot--fringe-action
    [#b0000000000000000
     #b0000001111000000
     #b0000111111110000
     #b0001111111111000
     #b0001100000011000
     #b0001100100011000
     #b0001100110011000
     #b0001100000011000
     #b0001111111111000
     #b0000111111110000
     #b0000111111100000
     #b0000001111000000
     #b0000001111000000
     #b0000001111000000
     #b0000001111000000
     #b0000000000000000]
    16 16 'center)

  ;; 极客性能优化：将 JSON-RPC 日志记录函数设为空操作，免去大量的字符串拼接开销
  (fset #'jsonrpc--log-event #'ignore))

;;; Icomplete / Fido - 垂直 Minibuffer 补全
(use-package icomplete
  :ensure nil
  :bind ("C-x C-r" . my-recentf-open)
  :init
  (fido-mode 1)                                ; 开启基于 Icomplete 的 Fido 模糊匹配
  (fido-vertical-mode 1)                       ; 切换为垂直列表模式
  :custom
  (icomplete-max-delay-chars 2)                ; 延迟触发字符限制
  (icomplete-hide-common-prefix nil)           ; 不隐藏公共前缀
  (icomplete-tidy-shadowed-file-names t)        ; 自动清理如 ~/foo/~/$HOME 等被覆盖的文件路径
  (icomplete-show-matches-on-no-input nil)    ; 未输入时不强制展示全量候选
  :config
  (defun my-fido-render-tab-cycle-selection (render completions metadata)
    "Keep Fido's highlight aligned with a candidate chosen by TAB.

Native minibuffer completion removes the candidate just inserted by TAB
from `completion-all-sorted-completions', so that the next TAB can select
the following candidate.  Fido normally highlights the first remaining
candidate, which makes its display appear one item ahead.  For an active
TAB cycle, temporarily prepend the current candidate for rendering only;
the underlying completion list is left untouched.
"
    (if (and fido-mode
            completion-cycling
           (eq this-command 'completion-at-point)
             (consp completions))
         (let* ((base-size (cdr (last completions)))
                (current (icomplete--field-string))
               ;; ;; File completion candidates omit the unchanged directory
               ;; ;; portion.  Use the base size encoded in the list to render
               ;; ;; the same text as the other Fido candidates.
                (current (if (and (integerp base-size)
                                  (<= base-size (length current)))
                             (substring current base-size)
                           current)))
           (funcall render (cons current completions) metadata))
       (funcall render completions metadata)))




  (advice-add 'icomplete--render-vertical :around
              #'my-fido-render-tab-cycle-selection)

  (defun my-recentf-open ()
    (interactive)
    (let ((file (completing-read "Find recent file: " recentf-list nil t)))
      (if (and file (file-exists-p file))
          (find-file file)
        (message "File open failed")))))

;;; Completion Preview - 内置行内补全预判 (Emacs 30+)
(use-package completion-preview
  :ensure nil
  :if (eq nn-completion-style 'completion-preview) ; 仅当补全风格变量为 'completion-preview 时启用
  :bind
  (:map completion-preview-active-mode-map
   ("C-n" . completion-preview-next-candidate)
   ("C-p" . completion-preview-prev-candidate)
   ("C-l" . (lambda () (interactive)
              (completion-preview-hide)
              (completion-preview-next-candidate))))
  :custom
  (completion-preview-ignore-case t)
  (completion-preview-minimum-symbol-length nil)
  (completion-preview-completion-styles '(basic partial-completion initials orderless)))

;;; Corfu - 现代浮窗代码补全
(use-package corfu
  :if (eq nn-completion-style 'corfu)          ; 仅当补全风格变量为 'corfu 时启用
  :bind
  (:map corfu-map
   ([tab] . corfu-complete)                   ; TAB 确认选中
   ("<return>" . corfu-complete)              ; 回车确认选中
   ([backtab] . corfu-previous)               ; Shift+TAB 上一个候选
   ("<escape>" . corfu-quit)                  ; ESC 退出补全
   ("S-SPC" . corfu-insert-separator))        ; Shift+Space 插入 Orderless 分隔符
  :hook (nn-first-input . global-corfu-mode)   ; 首次输入时延迟激活全局 Corfu
  :custom
  (corfu-auto t)                              ; 自动弹出补全窗口
  (corfu-auto-delay 0.2)                      ; 延迟 0.2 秒弹出
  (corfu-auto-prefix 2)                       ; 输入至少 2 个字符后触发
  (corfu-auto-commands                        ; 允许触发自动补全的命令白名单
   '("self-insert-command\\'"
     c-electric-colon c-electric-lt-gt
     c-electric-slash c-scope-operator
     lispy-colon))
  (corfu-preselect 'first)                    ; 默认自动高亮第一个候选项
  (corfu-quit-at-boundary nil)                ; 移动到边界时不立即退出
  (corfu-quit-no-match t)                     ; 无匹配候选时自动退出
  (corfu-preview-current nil)                 ; 不在代码中实时预览未确认的候选词
  (corfu-count 12)                            ; 最多显示 12 条候选
  (corfu-max-width 120)                       ; 浮窗最大宽度 120
  (corfu-left-margin-width 0)                 ; 左右留白宽度设为 0
  (corfu-right-margin-width 0)
  (global-corfu-minibuffer nil)               ; 不在 Minibuffer 中启用 Corfu
  (global-corfu-modes '((not erc-mode help-mode gud-mode) t)) ; 黑名单模式排除
  :config
  ;; HACK: 解决退出 Minibuffer 时 Corfu 补全残影/Timer 冲突问题
  (define-advice exit-minibuffer
      (:before () my-corfu--insert-before-exit-minibuffer-a)
    (when (or (and (frame-live-p corfu--frame)
                   (frame-visible-p corfu--frame))
              (and (featurep 'corfu-terminal)
                   (popon-live-p corfu-terminal--popon)))
      ;; 强制手动执行处于挂起状态的 Idle Timer，清理残影
      (when (member isearch-lazy-highlight-timer timer-idle-list)
        (apply (timer--function isearch-lazy-highlight-timer)
               (timer--args isearch-lazy-highlight-timer)))
      (when (member (bound-and-true-p anzu--update-timer) timer-idle-list)
        (apply (timer--function anzu--update-timer)
               (timer--args anzu--update-timer)))
      (when (member (bound-and-true-p evil--ex-search-update-timer)
                    timer-idle-list)
        (apply (timer--function evil--ex-search-update-timer)
               (timer--args evil--ex-search-update-timer)))))

  ;; HACK: 捕获并防止 ispell 字典缺失导致的持续报错风暴
  (define-advice ispell-completion-at-point
      (:around (fn &rest args) my-corfu--auto-disable-ispell-capf-a )
    "If ispell isn't properly set up, only complain once per session."
    (condition-case-unless-debug e
        (apply fn args)
      ('error
       (message "Error: %s" (error-message-string e))
       (message "Auto-disabling `text-mode-ispell-word-completion'")
       (setq text-mode-ispell-word-completion nil)
       ;; 发生异常时静默将 ispell 从 CAPF 补全列表中彻底移除
       (remove-hook 'completion-at-point-functions #'ispell-completion-at-point t)))))

;;; Corfu Popupinfo - 浮窗候选词文档预览
(use-package corfu-popupinfo
  :ensure nil
  :bind
  (:map corfu-map
   ("M-p" . my-corfu-popupinfo-toggle)         ; M-p 切换文档显示/隐藏
   ("M-1" . corfu-popupinfo-scroll-up)        ; M-1 向上滚动文档
   ("M-2" . corfu-popupinfo-scroll-down))     ; M-2 向下滚动文档
  :custom (corfu-popupinfo-delay '(0 . 0.2))   ; 触发文档展示的延迟时间
  :config
  ;; 交互式开关文档浮窗函数
  (defun my-corfu-popupinfo-toggle ()
    (interactive)
    (corfu-popupinfo-mode (not corfu-popupinfo-mode)))

  ;; 退出 Corfu 时自动关闭 popupinfo 模式
  (define-advice corfu-quit (:after (&rest _) my-corfu-popupinfo-quit)
    (when corfu-popupinfo-mode
      (corfu-popupinfo-mode -1))))

;;; Yasnippet - 模板片段扩展
(use-package yasnippet
  :commands
  (yas-minor-mode-on
   yas-expand
   yas-expand-snippet
   yas-lookup-snippet
   yas-insert-snippet
   yas-new-snippet
   yas-visit-snippet-file
   yas-activate-extra-mode
   yas-deactivate-extra-mode
   yas-maybe-expand-abbrev-key-filter)
  :hook (nn-first-input . yas-global-mode))      ; 首次输入时延迟全量激活

(provide 'init-completion)

;;; init-completion.el --- Modern Vertico Completion Suite -*- lexical-binding: t; -*-

;; ============================================================================
;; 1. Vertico: 垂直交互补全 UI 界面
;; ============================================================================
(use-package vertico
  :straight t
  :init
  (vertico-mode 1)
  :config
  ;; 设置补全显示行数
  (setq vertico-count 13)
  ;; 允许在列表上下滚动时循环选择
  (setq vertico-cycle t)
  ;; 在 Minibuffer 顶部增加当前选择项的缩进，提升视觉对比度
  (setq vertico-resize t))

;; 保存 Minibuffer 输入历史，以便下次打开时使用 M-p/M-n 翻阅
(use-package savehist
  :init
  (savehist-mode 1))

;; ============================================================================
;; 2. Orderless: 强大的无序/模糊匹配引擎
;;    例：输入 "init completion" 即可匹配到 "init-completion.el"
;; ============================================================================
(use-package orderless
  :straight t
  :custom
  ;; 默认匹配风格优先使用 orderless，退回 basic
  (completion-styles '(orderless basic))
  ;; 文件路径补全时，保留原生的 partial-completion (方便通配符如 ~/p/s -> ~/Projects/src)
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; ============================================================================
;; 3. Marginalia: 为补全列表添加丰富的信息标注 (如文件大小、文档说明、快捷键)
;; ============================================================================
(use-package marginalia
  :straight t
  :init
  (marginalia-mode 1))

;; ============================================================================
;; 4. Consult: 提供现代化的实用交互搜索命令 (替代 Swiper / Counsel)
;; ============================================================================
(use-package consult
  :straight t
  :defer t
  :init
  ;; 用 Consult 替换原生的默认 Regisiter/Xref 交互
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)
  (advice-add #'register-preview :override #'consult-register-window)
  :config
  ;; 配置 Consult 预览延迟 (0.2秒后自动实时预览文件/Buffer 内容)
  (setq consult-preview-key '(:debounce 0.2 any)))

;; ============================================================================
;; 5. Embark: 补全列表中的“右键菜单”与动作触发引擎
;;    结合 Avy 可以在补全列表中实现“隔空选中/隔空执行”
;; ============================================================================
(use-package embark
  :straight t
  :defer t
  :init
  ;; 设置 C-. 为超级右键菜单（在任何位置/补全列表中触发）
  :general
  ("C-." '("context actions" . embark-act))
  ("M-." '("default context action" . embark-dwim))
  ("C-h B" '("Embark bindings" . embark-bindings))
  :config
  ;; 执行动作后隐藏 Embark 提示框
  (add-hook 'embark-collect-post-revert-hook #'consult-revert-config))

;; 整合 Embark 与 Consult (提供类似 Counsel-collect-snapshot 的流转能力)
(use-package embark-consult
  :straight t
  :after (embark consult)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; ============================================================================
;; 6. 配合 General.el 集中绑定 Leader 键
;; ============================================================================
(with-eval-after-load 'general
  (my-leader-def
    ;; 搜索与定位 (Search)
    "ss"  '("search current buffer" . consult-line)
    "sS"  '("search open buffers" . consult-line-multi)
    "sp"  '("search project (rg)" . consult-ripgrep)
    "sf"  '("find file with fd/find" . consult-find)
    "sg"  '("search git repo" . consult-git-grep)
    "si"  '("imenu code symbols" . consult-imenu)
    "sb"  '("bookmarks" . consult-bookmark)

    ;; Buffer 与文件增强
    "b b" '("switch buffer/recentf" . consult-buffer)
    "b B" '("switch buffer other window" . consult-buffer-other-window)
    "f r" '("recent files" . consult-recent-file)

    ;; 跳转
    "j m" '("jump to mark" . consult-mark)
    "j e" '("jump to compile error" . consult-compile-error)

    ;; 剪贴历史是独立命令，不混入跳转菜单。
    "y" '("browse kill-ring" . consult-yank-pop)

    ;; 上下文动作
    "a a" '("context actions" . embark-act)
    "a d" '("default context action" . embark-dwim)
    "a b" '("show action bindings" . embark-bindings)
    "a e" '("export results" . embark-export)))

(provide 'init-completion)
;;; init-completion.el ends here

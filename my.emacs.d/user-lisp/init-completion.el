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
  :bind (("C-." . embark-act)
         ("M-." . embark-dwim)
         ("C-h B" . embark-bindings))
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
    "s"   '(:ignore t :which-key "Search/Consult")
    "ss"  '(consult-line          :which-key "search current buffer")
    "sS"  '(consult-line-multi    :which-key "search open buffers")
    "sp"  '(consult-ripgrep       :which-key "search project (rg)")
    "sf"  '(consult-find          :which-key "find file with fd/find")
    "sg"  '(consult-git-grep      :which-key "search git repo")
    "si"  '(consult-imenu         :which-key "imenu code symbols")
    "sb"  '(consult-bookmark      :which-key "bookmarks")

    ;; Buffer 与文件增强
    "b b" '(consult-buffer        :which-key "switch buffer/recentf")
    "b B" '(consult-buffer-other-window :which-key "switch buffer other window")
    "f r" '(consult-recent-file   :which-key "recent files")

    ;; 跳转与历史 (Go/History)
    "g m" '(consult-mark          :which-key "jump to mark")
    "g y" '(consult-yank-pop      :which-key "browse kill-ring (paste history)")
    "g e" '(consult-compile-error :which-key "jump to compile error")))

(provide 'init-completion)
;;; init-completion.el ends here
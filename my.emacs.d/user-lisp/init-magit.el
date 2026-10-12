;;; init-magit.el --- Magit & Ediff Integration Configuration -*- lexical-binding: t; -*-

;; 1. Magit 核心配置
(use-package magit
  :ensure t
  :general
  ("C-x g" '(magit-status :which-key "Magit status"))
  ("C-x M-g" '(magit-dispatch :which-key "Magit dispatch"))
  ("C-c f g" '(magit-file-dispatch :which-key "Magit file actions"))

  :custom
  ;; 性能与显示优化
  (magit-diff-refine-hunk 'all)             ; 高亮显示差异块的具体变动字符
  (magit-save-repository-buffers 'autosave) ; 执行 Git 操作前自动保存相关 Buffer

  :config
  ;; 让 Magit Status 全屏全窗口打开，按 q 退出时自动还原之前的窗口布局
  (setq magit-display-buffer-function
        #'magit-display-buffer-same-window-except-diff-v1))

;; 2. 在内置的 project.el 中集成 Magit (可选)
(with-eval-after-load 'project
  (general-define-key
    :keymaps 'project-prefix-map
    "m" '(magit-project-status :which-key "Magit project status"))
  (add-to-list 'project-switch-commands '(magit-project-status "Magit" ?m)))

(with-eval-after-load 'general
  (my-leader-def
    "g s" '(magit-status :which-key "status")
    "g d" '(magit-dispatch :which-key "dispatch")
    "g f" '(magit-file-dispatch :which-key "file actions")
    "g p" '(magit-project-status :which-key "project status")))

(provide 'init-magit)
;;; init-magit.el ends herejj

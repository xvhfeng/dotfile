;;; init-magit.el --- Magit & Ediff Integration Configuration -*- lexical-binding: t; -*-

;; 1. Magit 核心配置
(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)           ; 打开 Git 状态面板
         ("C-x M-g" . magit-dispatch)       ; 调用特定 Magit 命令快捷弹框
         ("C-c f g" . magit-file-dispatch)) ; 对当前文件执行 Git 操作（如 Blame、Log）

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
  (define-key project-prefix-map (kbd "m") #'magit-project-status)
  (add-to-list 'project-switch-commands '(magit-project-status "Magit" ?m)))

(provide 'init-magit)
;;; init-magit.el ends herejj

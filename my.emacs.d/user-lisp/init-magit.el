;;; init-magit.el --- Magit & Ediff Integration Configuration -*- lexical-binding: t; -*-

;; 1. Magit 核心配置
(use-package magit
  :ensure t
  :general
  ("C-x g" '("Magit status" . magit-status))
  ("C-x M-g" '("Magit dispatch" . magit-dispatch))
  ("C-c f g" '("Magit file actions" . magit-file-dispatch))

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
    "m" '("Magit project status" . magit-project-status))
  (add-to-list 'project-switch-commands '(magit-project-status "Magit" ?m)))

(with-eval-after-load 'general
  (my-leader-def
    "g s" '("status" . magit-status)
    "g d" '("dispatch" . magit-dispatch)
    "g f" '("file actions" . magit-file-dispatch)
    "g p" '("project status" . magit-project-status)))

(provide 'init-magit)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `C-x g' 或 `C-c g s' 打开仓库状态；`C-x M-g' 或 `C-c g d' 打开 Magit Dispatch。
;; - `C-c f g' 或 `C-c g f' 操作当前文件；`C-c g p' 打开当前项目状态。
;; - 在 project.el 的项目菜单中按 `m' 也可进入 Magit 项目状态。
;; - Status 中常用 `s/u' 暂存/取消暂存，`c c' 提交，`P p' 推送，`F p' 拉取，`q' 返回。
;; - Git 操作前自动保存仓库 Buffer；Status 使用当前窗口并在退出后恢复原布局。
;;; init-magit.el ends here

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

;; Magit 的 section 界面原生使用 n/p 上下移动，但多数人更习惯 Vim 的 j/k。
;; 这里保留 n/p 兼容键，将被替换的 j/k 专用操作迁移到 C-j/C-k；J/K 保留
;; Magit 原有的仓库缓冲区与 untrack 语义，不引入新的大写键冲突。
(defun my/magit--bind-jk-navigation (map down up &optional old-j)
  "在 MAP 中将 j/k 绑定为 DOWN/UP，并可把 OLD-J 移至 C-j。"
  (when (keymapp map)
    (define-key map (kbd "j") down)
    (define-key map (kbd "k") up)
    (when old-j
      (define-key map (kbd "C-j") old-j))
    ;; Magit section 界面的旧 k 都是 `magit-delete-thing'。
    (when (fboundp 'magit-delete-thing)
      (define-key map (kbd "C-k") #'magit-delete-thing))))

(defun my/magit-configure-jk-navigation ()
  "统一 Magit 浏览界面的 j/k 上下导航及旧 j/k 操作迁移。"
  (interactive)
  ;; 所有 section 派生界面的默认导航。
  (when (boundp 'magit-section-mode-map)
    (my/magit--bind-jk-navigation magit-section-mode-map
                                   #'magit-section-forward
                                   #'magit-section-backward))
  ;; 这些界面各自定义了 j；它们的原操作改为 C-j。
  (dolist (spec '((magit-mode-map . magit-status-quick)
                  (magit-status-mode-map . magit-status-jump)
                  (magit-diff-mode-map . magit-jump-to-diffstat-or-diff)
                  (magit-revision-mode-map . magit-revision-jump)
                  (magit-log-mode-map . magit-log-move-to-revision)
                  (magit-reflog-mode-map . magit-log-move-to-revision)
                  (magit-log-select-mode-map . magit-log-move-to-revision)
                  (magit-refs-mode-map . magit-status-quick)
                  (magit-process-mode-map . magit-status-quick)
                  (magit-cherry-mode-map . magit-status-quick)))
    (when (boundp (car spec))
      (my/magit--bind-jk-navigation (symbol-value (car spec))
                                     #'magit-section-forward
                                     #'magit-section-backward
                                     (cdr spec))))
  ;; Repolist 不是 section mode，沿用 tabulated-list 的行移动函数。
  (when (boundp 'magit-repolist-mode-map)
    (my/magit--bind-jk-navigation magit-repolist-mode-map
                                   #'next-line #'previous-line))
  ;; Blame 以提交块为单位导航，不能使用 section 函数。
  (when (boundp 'magit-blame-read-only-mode-map)
    (my/magit--bind-jk-navigation magit-blame-read-only-mode-map
                                   #'magit-blame-next-chunk
                                   #'magit-blame-previous-chunk))
  ;; Rebase todo 是可编辑行列表；原 k 删除行已保留在 C-k。
  (when (boundp 'git-rebase-mode-map)
    (define-key git-rebase-mode-map (kbd "j") #'forward-line)
    (define-key git-rebase-mode-map (kbd "k") #'git-rebase-backward-line)
    (define-key git-rebase-mode-map (kbd "C-k") #'git-rebase-kill-line))
  ;; Which-Key 在 Magit 本地 map 中显示迁移后的导航与保留操作说明。
  (when (fboundp 'which-key-add-keymap-based-replacements)
    (dolist (map-symbol '(magit-section-mode-map magit-mode-map
                          magit-status-mode-map magit-diff-mode-map
                          magit-revision-mode-map magit-log-mode-map
                          magit-reflog-mode-map magit-log-select-mode-map
                          magit-refs-mode-map magit-process-mode-map
                          magit-cherry-mode-map))
      (when (boundp map-symbol)
        (which-key-add-keymap-based-replacements
         (symbol-value map-symbol)
         "j" "下一节" "k" "上一节"
         "C-j" "原 j 专用操作" "C-k" "原 k 删除操作")))
    (when (boundp 'magit-repolist-mode-map)
      (which-key-add-keymap-based-replacements
       magit-repolist-mode-map "j" "下一行" "k" "上一行"))
    (when (boundp 'magit-blame-read-only-mode-map)
      (which-key-add-keymap-based-replacements
       magit-blame-read-only-mode-map "j" "下一提交块" "k" "上一提交块"))
    (when (boundp 'git-rebase-mode-map)
      (which-key-add-keymap-based-replacements
       git-rebase-mode-map "j" "下一行" "k" "上一行" "C-k" "删除待变基行"))))

;; Magit 子模块按需加载时也应用相同规则，避免只在 Status 中生效。
(dolist (feature '(magit-section magit-mode magit-status magit-diff
                   magit-log magit-reflog magit-refs magit-process
                   magit-repos magit-blame git-rebase))
  (eval-after-load feature '(my/magit-configure-jk-navigation)))

(with-eval-after-load 'magit
  (my/magit-configure-jk-navigation))

;; 2. 在内置的 project.el 中集成 Magit (可选)
(with-eval-after-load 'project
  (general-define-key
    :keymaps 'project-prefix-map
    "m" '("Magit 项目状态" . magit-project-status))
  (add-to-list 'project-switch-commands '(magit-project-status "Magit" ?m)))

(with-eval-after-load 'general
  (my-leader-def
    "g s" '("仓库状态" . magit-status)
    "g d" '("Git 操作菜单" . magit-dispatch)
    "g f" '("当前文件操作" . magit-file-dispatch)
    "g p" '("项目状态" . magit-project-status)))

(provide 'init-magit)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - `C-x g' 或 `C-c g s' 打开仓库状态；`C-x M-g' 或 `C-c g d' 打开 Magit Dispatch。
;; - `C-c f g' 或 `C-c g f' 操作当前文件；`C-c g p' 打开当前项目状态。
;; - 在 project.el 的项目菜单中按 `m' 也可进入 Magit 项目状态。
;; - Status 中常用 `s/u' 暂存/取消暂存，`c c' 提交，`P p' 推送，`F p' 拉取，`q' 返回。
;; - Status、Diff、Log、Refs 等浏览界面以 `j/k' 下/上移动；`n/p' 保留兼容。
;;   被替换的原 `j/k' 操作使用 `C-j/C-k'，`J/K' 保持原有语义。
;; - Git 操作前自动保存仓库 Buffer；Status 使用当前窗口并在退出后恢复原布局。
;;; init-magit.el ends here

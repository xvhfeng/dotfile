;;; init-completion.el --- Modern Vertico Completion Suite -*- lexical-binding: t; -*-

;; Vertico、Orderless、Marginalia 与 Savehist 只在 init-minbuffer.el 初始化。
;; 本文件负责 Consult 的动作层（Embark）与统一快捷键，避免同一套补全栈
;; 被重复启用、覆盖变量并重复执行 mode hook。

;; ============================================================================
;; 1. Embark: 补全列表中的“右键菜单”与动作触发引擎
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
  ("C-c E" '("export results" . embark-export))
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
;; 2. 配合 General.el 集中绑定 Leader 键
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

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 本模块在 Minibuffer 基础上提供 Consult 搜索、Embark 上下文动作及结果预览。
;; - `C-c s s/S/p/f/g/i/b'：当前 Buffer/多 Buffer/项目/文件/Git/符号/书签搜索。
;; - `C-c b b/B' 切换 Buffer（当前/其他窗口）；`C-c f r' 打开最近文件。
;; - `C-c j m/e' 跳 Mark/编译错误；`C-c y' 浏览剪贴历史。
;; - `C-.' 或 `C-c a a' 打开上下文动作，`M-.' 或 `C-c a d' 执行默认动作。
;; - `C-c a b/e' 查看动作绑定/导出结果；候选默认在短延迟后实时预览。
;;; init-completion.el ends here

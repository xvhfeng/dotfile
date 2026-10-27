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
  ;; 中文说明：M-. 用于打开 Embark 动作菜单；C-. 显式解绑，避免它在帮助
  ;; 的按键读取或日常编辑中成为难以发现的全局拦截键。
  :general
  ("M-." '("context actions" . embark-act))
  ("C-." nil)
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
    "ss"  '("搜索当前缓冲区〔Consult〕" . consult-line)
    "sS"  '("搜索已打开缓冲区〔Consult〕" . consult-line-multi)
    "sp"  '("搜索项目〔Consult〕" . consult-ripgrep)
    "sf"  '("查找文件〔Consult〕" . consult-find)
    "sg"  '("搜索 Git 仓库〔Consult〕" . consult-git-grep)
    "si"  '("代码符号列表〔Consult〕" . consult-imenu)
    "sb"  '("书签〔Consult〕" . consult-bookmark)

    ;; Buffer 与文件增强
    "b b" '("切换缓冲区或最近文件" . consult-buffer)
    "b B" '("在其他窗口切换缓冲区" . consult-buffer-other-window)
    "f r" '("最近文件" . consult-recent-file)

    ;; 跳转
    "j m" '("跳转到标记" . consult-mark)
    "j e" '("跳转到编译错误" . consult-compile-error)

    ;; 剪贴历史是独立命令，不混入跳转菜单。
    "y" '("查看剪贴历史" . consult-yank-pop)

    ;; 上下文动作
    "a a" '("上下文操作" . embark-act)
    "a d" '("默认上下文操作" . embark-dwim)
    "a b" '("显示操作按键" . embark-bindings)
    "a e" '("导出结果" . embark-export)))

(provide 'init-completion)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 本模块在 Minibuffer 基础上提供 Consult 搜索、Embark 上下文动作及结果预览。
;; - `C-c s s/S/p/f/g/i/b'：当前 Buffer/多 Buffer/项目/文件/Git/符号/书签搜索。
;; - `C-c b b/B' 切换 Buffer（当前/其他窗口）；`C-c f r' 打开最近文件。
;; - `C-c j m/e' 跳 Mark/编译错误；`C-c y' 浏览剪贴历史。
;; - `M-.' 或 `C-c a a' 打开上下文动作；`C-c a d' 执行默认动作。
;; - `C-c a b/e' 查看动作绑定/导出结果；候选默认在短延迟后实时预览。
;;; init-completion.el ends here

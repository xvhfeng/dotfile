;;; -*- lexical-binding: t; -*-

;; 只向字节编译器声明 project.el API，不在这里提前加载 project.el。
;; 这样既消除编译警告，也避免与 straight 安装的 project 包争抢 feature。
(declare-function project-current "project" (&optional maybe-prompt dir))
(declare-function project-root "project" (project))
;; `consult-customize' 展开后会调用此函数；声明它可避免延迟加载时的字节编译误报。
(declare-function consult--customize-put "consult" (commands property form))

;; 必须先让 straight 将集成包加入 `load-path'。否则本文件在冷启动时
;; 先加载 Consult 与 Embark，Embark 会误报 embark-consult 尚未安装。
(use-package embark-consult
  :straight t
  :defer t)

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

;; ============================================================================
;; 2. Consult + Ripgrep 自定义项目搜索配置
;; ============================================================================

(use-package consult
  :straight t
  :defer t
  :general
  ("C-c p s" '("search project" . consult-ripgrep))
  ("M-s r" '("ripgrep project" . consult-ripgrep))
  ("M-s l" '("search current buffer" . consult-line))
  ("M-s f" '("find file" . consult-find))
  ("C-c ! l" '("list diagnostics" . consult-flymake))

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

  ;; 快速移动候选时不再逐个打开文件。停留 0.4 秒仍会自动预览，
  ;; 因此保留了原有实时预览能力，只减少无意义的磁盘读取和重绘。
  (consult-customize
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   consult-source-buffer consult-source-project-buffer
   consult-source-buffer-register
   :preview-key '(:debounce 0.4  any)))



;; 挂载到 General.el 体系下的诊断菜单 (C-c c d ...)
(with-eval-after-load 'general
  (my-leader-def
    "c d l" '("search diagnostics" . consult-flymake)))


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
;; 导出： 在 Minibuffer 结果列表中，按下 C-. E（即调用 embark-act 然后按 E 执行 embark-export），这会将搜索结果导出到一个 *grep* 缓冲区。
;; 可编辑替换：
;; 在 *grep* 缓冲区中，按下 C-c C-p（进入 wgrep-change-to-wgrep-mode 模式）。
;; 此时该缓冲区变为可编辑状态！你可以直接用 M-% (query-replace) 或 C-M-% (query-replace-regexp) 在这个 Buffer 中批量替换。
;; 保存改动： 替换完成后，按下 C-c C-c，wgrep 会自动将修改写入对应的所有物理磁盘文件；如果想放弃，按 C-c C-k。

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 含 `.projx' 的目录会被识别为项目根目录；项目搜索忽略 .git/node_modules/target/dist/log。
;; - `C-c p s' 或 `M-s r' 搜索项目，`M-s l' 搜索当前 Buffer，`M-s f' 查找文件。
;; - `C-c ! l' 或 `C-c c d l' 汇总 Flymake 诊断；`C-c E' 导出当前候选结果。
;; - 批量替换流程：Consult 搜索 -> `C-. E' 导出 -> `C-c C-p' 进入 Wgrep。
;; - 在 Wgrep 中编辑后按 `C-c C-c' 写回文件，按 `C-c C-k' 放弃全部修改。

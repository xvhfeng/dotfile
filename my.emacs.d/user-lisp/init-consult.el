;;; -*- lexical-binding: t; -*-

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
  :bind (("C-c p s" . consult-ripgrep)       ; 全局/项目根目录 Ripgrep 实时预览搜索
         ("M-s r"   . consult-ripgrep)       ; 遵循 Emacs 标准 M-s 前缀
         ("M-s l"   . consult-line)          ; 当前 Buffer 实时文本搜索
         ("M-s f"   . consult-find))         ; 实时预览文件名搜索

  :custom
  ;; 开启光标移动即时预览
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
            (project-root proj)))))

;; ============================================================================
;; Embark + wgrep: 搜索结果导出与批量重构 (可选但强烈推荐)
;; ============================================================================

(use-package embark
  :straight t
  :bind (("C-c E" . embark-export)))         ; 在 consult-ripgrep 中按 C-c E 导出为 Buffer

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

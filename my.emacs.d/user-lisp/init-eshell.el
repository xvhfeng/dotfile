;;; init-eshell.el --- Lazy vterm integration -*- lexical-binding: t; -*-

(defvar load-path-filter-function)

;; ============================================================================
;; 内置 Term / Ansi-Term 现代化增强配置
;; ============================================================================

;; ============================================================================
;; 基于 C 语言的高性能 Terminal —— vterm
;; 完全加载 macOS Bash 环境、环境变量、别名与自定义函数
;; 前提条件：需在系统终端执行 brew install cmake libvterm
;; ============================================================================

(setq eshell-directory-name (my/runtime-file "eshell/"))
(make-directory eshell-directory-name t)

(defun my/vterm-ensure-module-file ()
  "Make CMake's macOS module artifact discoverable by Emacs."
  (let* ((build-directory
          (expand-file-name "straight/build/vterm/" user-emacs-directory))
         (vterm-library (locate-library "vterm.el" t))
         ;; straight can load vterm by absolute path without adding its build
         ;; directory to load-path.  Native modules still require that path.
         (vterm-directory (if (file-directory-p build-directory)
                              build-directory
                            (and vterm-library
                                 (file-name-directory vterm-library))))
         (expected-module (and vterm-directory
                               (expand-file-name
                                (concat "vterm-module" module-file-suffix)
                                vterm-directory)))
         (cmake-module (and vterm-directory
                            (expand-file-name "vterm-module.so" vterm-directory))))
    (when (and expected-module
               (not (file-exists-p expected-module))
               (file-exists-p cmake-module))
      (make-symbolic-link "vterm-module.so" expected-module t))
    (when vterm-directory
      (add-to-list 'load-path vterm-directory))))

(use-package vterm
  :straight t
  :commands vterm
  :init
  ;; 只准备模块路径，不在启动阶段加载 vterm 或原生动态库。
  (my/vterm-ensure-module-file)
  :custom
  ;; 指定调用的 Shell 为 macOS 的 Bash
  (vterm-shell "/bin/bash")
  ;; 设置最大历史滚动行数
  (vterm-max-scrollback 10000)

  :config
  ;; 缓存的 load-path 目录列表不包含原生模块，打开终端时再加载。
  (let ((load-path-filter-function nil))
    (require 'vterm-module nil t))
  ;; 在终端里退出 (exit) 时，自动销毁并关闭当前 Buffer
  (setq vterm-kill-buffer-on-exit t)

  ;; 优化 vterm 界面：关闭行号与当前行高亮
  (add-hook 'vterm-mode-hook
            (lambda ()
              (when (fboundp 'display-line-numbers-mode)
                (display-line-numbers-mode -1))
              (when (fboundp 'hl-line-mode)
                (hl-line-mode -1)))))

(with-eval-after-load 'vterm
  (general-define-key
   :keymaps 'vterm-mode-map
   "C-y" '("粘贴" . vterm-yank)
   "M-x" '("M-x" . execute-extended-command)
   "C-x C-f" '("打开文件" . find-file)
   "C-x b" '("切换缓冲区" . switch-to-buffer)
   "C-x k" '("关闭缓冲区" . kill-current-buffer)
   "C-x o" '("其他窗口" . other-window)))

(with-eval-after-load 'general
  (my-leader-def
    "x t" '("终端" . vterm)))

(provide 'init-eshell)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 文件名保留为 init-eshell，但当前实际配置的是高性能 vterm 终端。
;; - `C-c x t' 打开 vterm；终端内执行 `exit' 会自动关闭其 Buffer。
;; - vterm 中 `C-y' 粘贴；`M-x'、`C-x C-f/b/k/o' 仍可调用 Emacs 命令。
;; - 默认 Shell 为 `/bin/bash'，历史上限 10000 行；终端 Buffer 隐藏行号和当前行高亮。
;; - 首次编译需系统安装 CMake 与 libvterm；模块加载失败时先检查这两个依赖。
;; - Eshell 自身的数据目录仍被迁移到 `.local/eshell/'。

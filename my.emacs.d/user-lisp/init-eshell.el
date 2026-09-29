
;;; -*- lexical-binding: t; -*-

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

;; This must happen before use-package can require vterm.
(my/vterm-ensure-module-file)
;; The cached load-path directory listing omits native modules.
;; Bypass it only while loading this module.
(let ((load-path-filter-function nil))
  (require 'vterm-module nil t))

(use-package vterm
  :straight t
  :demand t
  :bind (("C-c t" . vterm)              ; 全局快捷键 C-c t 快速调出/新建 vterm
         :map vterm-mode-map
         ("C-y"     . vterm-yank)       ; 支持 Emacs 剪贴板粘贴
         ("M-x"     . execute-extended-command)
         ("C-x C-f" . find-file)
         ("C-x b"   . switch-to-buffer)
         ("C-x k"   . kill-current-buffer)
         ("C-x o"   . other-window))
  :custom
  ;; 指定调用的 Shell 为 macOS 的 Bash
  (vterm-shell "/bin/bash")
  ;; 设置最大历史滚动行数
  (vterm-max-scrollback 10000)

  :config
  ;; 在终端里退出 (exit) 时，自动销毁并关闭当前 Buffer
  (setq vterm-kill-buffer-on-exit t)

  ;; 优化 vterm 界面：关闭行号与当前行高亮
  (add-hook 'vterm-mode-hook
            (lambda ()
              (when (fboundp 'display-line-numbers-mode)
                (display-line-numbers-mode -1))
              (when (fboundp 'hl-line-mode)
                (hl-line-mode -1)))))

(provide 'init-eshell)

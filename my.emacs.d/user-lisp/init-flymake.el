;;; init-flymake.el --- Flymake & Eglot Diagnostics Config -*- lexical-binding: t; -*-

;; ============================================================================
;; 0. Emacs Lisp 的受信任配置目录
;; ============================================================================
;; Emacs 30 为防止未受信任文件在 Flymake 字节编译时执行代码，会默认禁用 Elisp
;; 的字节编译和 Checkdoc 后端。用户已明确要求所有代码均可检查，因此这里启用 :all；
;; 请只对可信来源的 Elisp 文件使用此配置，未知来源的文件可能在检查期间执行代码。
(when (boundp 'trusted-content)
  (setq trusted-content :all))

;; ============================================================================
;; 1. Flymake 核心配置与外观增强
;; ============================================================================
(use-package flymake
  :ensure nil                          ; 内置包无需从外部下载
  :hook
  ;; 中文说明：为全部编程模式和常见 Web/配置代码模式自动开启 Flymake。
  ;; C、Java、Python 等的语义诊断由 Eglot 已连接的语言服务器提供。
  ((prog-mode . flymake-mode)
   (html-mode . flymake-mode)
   (html-ts-mode . flymake-mode)
   (mhtml-mode . flymake-mode)
   (mhtml-ts-mode . flymake-mode)
   (web-mode . flymake-mode)
   (css-mode . flymake-mode)
   (css-ts-mode . flymake-mode)
   (json-ts-mode . flymake-mode)
   (yaml-ts-mode . flymake-mode))
  :custom
  ;; 诊断标记显示在左侧 Margin/Fringe 边栏
  (flymake-fringe-indicator-position 'left-fringe)
  ;; 输入停顿时触发校验的延迟时间（0.5秒），兼顾流畅度与性能
  (flymake-no-changes-timeout 0.5)
  ;; 光标移动到错误行时，自动在 Echo Area 显示详细错误信息
  (flymake-show-diagnostics-at-end-of-line nil)

  :config
  ;; 优化原生跳转快捷键
  (define-key flymake-mode-map (kbd "M-n") #'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-p") #'flymake-goto-prev-error))

;; ============================================================================
;; 2. 与 Eglot 的深度无缝联动
;; ============================================================================
;; Eglot 默认会自动将自身挂载为 Flymake 的 Backend。
;; 此处配置确保每次 Eglot 启动时，自动激活并刷新 Flymake。
(with-eval-after-load 'eglot
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              ;; 当 Eglot 启动时，强制开启 flymake-mode 并立即同步诊断结果
              (flymake-mode 1))))

;; ============================================================================
;; 3. 搭配 Consult (可选)：交互式搜索全 Buffer 诊断信息
;; ============================================================================
;; 如果你的配置中使用了 Consult，可以使用 consult-flymake 随时弹窗预览所有错误
(with-eval-after-load 'consult
  (with-eval-after-load 'flymake
    (define-key flymake-mode-map (kbd "C-c ! l") #'consult-flymake)))

;; ============================================================================
;; 4. 挂载到 General.el Leader 键体系 (SPC c ...)
;; ============================================================================
(with-eval-after-load 'general
  (my-leader-def
    "c !" '(flymake-show-buffer-diagnostics :which-key "list buffer diagnostics")
    "c n" '(flymake-goto-next-error          :which-key "next error")
    "c p" '(flymake-goto-prev-error          :which-key "previous error")
    "c B" '(flymake-show-project-diagnostics :which-key "list project diagnostics")))


(use-package flymake-popon
  :straight t
  :hook (flymake-mode . flymake-popon-mode)
  :custom
  (flymake-popon-method 'overlay)) ; 使用 overlay 浮窗在光标旁直接展示错误描述

(provide 'init-flymake)

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
  :straight nil                        ; 内置包无需从外部下载
  :general
  (:keymaps 'flymake-mode-map
   "M-n" '("next diagnostic" . flymake-goto-next-error)
   "M-p" '("previous diagnostic" . flymake-goto-prev-error))
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
  (flymake-show-diagnostics-at-end-of-line nil))

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
    (general-define-key
      :keymaps 'flymake-mode-map
      "C-c ! l" '("list diagnostics" . consult-flymake))))

;; ============================================================================
;; 4. 挂载到 General.el Leader 键体系 (C-c c ...)
;; ============================================================================
(with-eval-after-load 'general
  (my-leader-def
    "c d b" '("buffer diagnostics" . flymake-show-buffer-diagnostics)
    "c d a" '("all project diagnostics" . flymake-show-project-diagnostics)
    "c d n" '("next diagnostic" . flymake-goto-next-error)
    "c d p" '("previous diagnostic" . flymake-goto-prev-error)))


(condition-case err
    (use-package flymake-popon
      :straight t
      :hook (flymake-mode . flymake-popon-mode)
      :custom
      (flymake-popon-method 'overlay)) ; 使用 overlay 浮窗在光标旁直接展示错误描述
  (error (message "flymake-popon 未加载：%s" (error-message-string err))))

(provide 'init-flymake)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - Flymake 在编程和常用 Web/配置模式中自动开启；Eglot 连接后提供语言服务器诊断。
;; - `M-n/M-p' 或 `C-c c d n/p' 跳到下一条/上一条诊断。
;; - `C-c c d b/a' 显示当前 Buffer/整个项目的诊断；`C-c c d l' 交互搜索诊断。
;; - `C-c ! l' 是诊断列表的兼容入口；光标停在问题行时 flymake-popon 显示说明。
;; - 本配置允许可信 Elisp 在检查期间执行代码；不要对未知来源代码盲目运行 Flymake。

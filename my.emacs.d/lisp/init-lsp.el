;;; init-lsp.el --- Modern LSP, In-buffer Completion & Outline -*- lexical-binding: t; -*-

;; ============================================================================
;; 1. Corfu: 光标处的代码补全浮窗 (In-Buffer Completion UI)
;; ============================================================================
(use-package corfu
  :straight t
  :custom
  (corfu-cycle t)                ; 允许循环选择
  (corfu-auto t)                 ; 自动弹出补全 (无需手动敲触发键)
  (corfu-auto-prefix 2)          ; 输入 2 个字符后自动弹出
  (corfu-auto-delay 0.1)         ; 弹出延迟 (秒)
  (corfu-quit-at-boundary 'separator) ; 配合 orderless 无序空格匹配
  (corfu-echo-documentation nil) ; 关闭底部 Echo area 文档，避免干扰
  :init
  (global-corfu-mode 1)          ; 全局启用 Corfu
  (corfu-popupinfo-mode 1))      ; 开启侧边文档预览浮窗


;; 让 Corfu 也能在代码补全中使用 Orderless 的无序空格匹配能力
(use-package orderless
  :config
  ;; 增强代码补全匹配体验
  (add-hook 'corfu-mode-hook
            (lambda ()
              (setq-local completion-styles '(orderless basic)))))

;; 为 Corfu 补全浮窗加上漂亮的图标 (可选增强)
(use-package kind-icon
  :straight t
  :after corfu
  :custom
  (kind-icon-default-face 'corfu-default)
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;; ============================================================================
;; 2. Cape: 扩展代码补全补全源 (提供补全文件名、Dict、Snippet 等)
;; ============================================================================
(use-package cape
  :straight t
  :init
  ;; 增加全局常用的补全后端：文件路径、Dabbrev (当前 Buffer 单词)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

;; ============================================================================
;; 3. Eglot: 原生轻量级 LSP 客户端 (Emacs 29+ 内置)
;; ============================================================================
(use-package eglot
  ;; Eglot 在 Emacs 29+ 为内置，若使用旧版可解开下面这行的注释
  ;; :straight t
  :defer t
  :hook
  ;; 在你需要语言支持的 Major Mode 中自动启用 Eglot (按需添加)
  ((c-mode
    c++-mode
    c-ts-mode
    c++-ts-mode
    python-mode
    python-ts-mode
    rust-mode
    rust-ts-mode
    go-mode
    go-ts-mode) . eglot-ensure)

    :custom
  ;; 避免 LSP 频繁在 minibuffer 输出冗长的提示信息
  (eglot-ignored-server-capabilities '(:inlayHintProvider))
  ;; 禁用 Eglot 自动修改事件日志，提升高频输入性能
  (eglot-events-buffer-size 0)

  :config
  ;; 优化 performance：提高与 LSP 服务器通信吞吐量
  (setq read-process-output-max (* 1024 1024)) ; 1MB
  ;; 关闭不必要的 Eglot 详细日志以提升性能
  (setq eglot-events-buffer-size 0)
  ;; 让 Eglot 自动与 Corfu 联动 (设置 CAPF 优先级)
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (setq-local completion-at-point-functions
                          (list (cape-super-capf
                                 #'eglot-completion-at-point
                                 #'cape-file)))))
                                 
  ;; 保存文件时自动格式化 (可选)
  ;; (add-hook 'before-save-hook #'eglot-format-buffer)
  )

;; ============================================================================
;; 4. Outline / 代码结构大纲体系
;; ============================================================================

;; 方案 A: 实时搜索跳转的大纲 (结合已安装的 Consult)
;; 触发命令：`consult-imenu`

;; 方案 B: 侧边栏树状代码大纲 (Imenu-list)
(use-package imenu-list
  :straight t
  :defer t
  :custom
  (imenu-list-auto-resize t)
  (imenu-list-focus-after-activation t))

;; ============================================================================
;; 5. 配合 General.el 集中绑定 Leader 键
;; ============================================================================
(with-eval-after-load 'general
  (my-leader-def
    ;; LSP 相关功能 (Code / LSP)
    "c"   '(:ignore t :which-key "Code / LSP")
    "ca"  '(eglot-code-actions      :which-key "code action / quick fix")
    "cr"  '(eglot-rename            :which-key "rename symbol")
    "cf"  '(eglot-format            :which-key "format buffer/region")
    "cd"  '(xref-find-definitions   :which-key "go to definition")
    "cD"  '(xref-find-references    :which-key "find references")
    "ch"  '(eldoc                   :which-key "show hover doc")
    "cq"  '(eglot-shutdown          :which-key "stop lsp server")

    ;; 代码大纲与导航 (Outline / Imenu)
    "o"   '(:ignore t :which-key "Outline / Views")
    "oi"  '(consult-imenu           :which-key "jump to symbol (imenu)")
    "oI"  '(consult-imenu-multi     :which-key "jump to symbol (all buffers)")
    "ot"  '(imenu-list-smart-toggle :which-key "toggle outline sidebar")))

(provide 'init-lsp)
;;; init-lsp.el ends here
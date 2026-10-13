;;; init-lsp.el --- Eglot LSP、代码补全与结构大纲 -*- lexical-binding: t; -*-

;; ============================================================================
;; 1. Corfu: 光标处的代码补全浮窗 (In-Buffer Completion UI)
;; ============================================================================
;; 中文说明：Corfu 属于可选显示组件，安装失败时只跳过浮窗，不影响后续 Eglot/Flymake。
(condition-case err
    (use-package corfu
      :straight t
      :custom
      (corfu-cycle t) (corfu-auto t) (corfu-auto-prefix 2) (corfu-auto-delay 0.1)
      (corfu-quit-at-boundary 'separator) (corfu-echo-documentation nil)
      :init
      (global-corfu-mode 1)
      (corfu-popupinfo-mode 1))
  (error (message "Corfu 未加载：%s" (error-message-string err))))


;; 让 Corfu 也能在代码补全中使用 Orderless 的无序空格匹配能力
(use-package orderless
  :config
  ;; 增强代码补全匹配体验
  (add-hook 'corfu-mode-hook
            (lambda ()
              (setq-local completion-styles '(orderless basic)))))

;; 为 Corfu 补全浮窗加上漂亮的图标 (可选增强)
;; 中文说明：图标仅增强补全外观，不能影响核心语言服务的加载。
(condition-case err
    (use-package kind-icon
      :straight t
      :after corfu
      :custom (kind-icon-default-face 'corfu-default)
      :config (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))
  (error (message "kind-icon 未加载：%s" (error-message-string err))))

;; ============================================================================
;; 2. Cape: 扩展代码补全补全源 (提供补全文件名、Dict、Snippet 等)
;; ============================================================================
;; 中文说明：Cape 缺失时 Eglot 仍保留原生 CAPF 补全与诊断能力。
(condition-case err
    (use-package cape
      :straight t
      :init
      (add-to-list 'completion-at-point-functions #'cape-file)
      (add-to-list 'completion-at-point-functions #'cape-dabbrev))
  (error (message "Cape 未加载：%s" (error-message-string err))))

;; ============================================================================
;; 3. Eglot: 原生轻量级 LSP 客户端 (Emacs 29+ 内置)
;; ============================================================================
(defconst my/lsp-server-commands
  '((c-mode . "clangd") (c++-mode . "clangd")
    (c-ts-mode . "clangd") (c++-ts-mode . "clangd")
    (java-mode . "jdtls") (java-ts-mode . "jdtls")
    (python-mode . "pyright-langserver") (python-ts-mode . "pyright-langserver")
    (lua-mode . "lua-language-server") (lua-ts-mode . "lua-language-server")
    (js-mode . "typescript-language-server") (js-ts-mode . "typescript-language-server")
    (typescript-mode . "typescript-language-server")
    (typescript-ts-mode . "typescript-language-server") (tsx-ts-mode . "typescript-language-server")
    (js-json-mode . "vscode-json-language-server") (json-ts-mode . "vscode-json-language-server")
    (yaml-mode . "yaml-language-server") (yaml-ts-mode . "yaml-language-server")
    (sh-mode . "bash-language-server"))
  "主模式与对应 LSP 可执行文件的映射；用于避免缺少服务器时影响编辑。")

;; 仅当对应服务器存在时启动 Eglot，缺失依赖只给出提示而不让打开文件报错。
(defun my/lsp-maybe-ensure ()
  "在当前主模式存在本地语言服务器时安全启动 Eglot。"
  (let ((server (alist-get major-mode my/lsp-server-commands)))
    (when (and server (executable-find server))
      (eglot-ensure))))

(use-package eglot
  ;; Eglot 在 Emacs 29+ 为内置，若使用旧版可解开下面这行的注释
  ;; :straight t
  :defer t
  :hook
  ;; 统一由安全 Hook 启动，避免未安装语言服务器时干扰现有 major mode。
  ((c-mode
    c++-mode
    c-ts-mode
    c++-ts-mode
    java-mode
    java-ts-mode
    python-mode
    python-ts-mode
    lua-mode
    lua-ts-mode
    js-mode
    js-ts-mode
    typescript-mode
    typescript-ts-mode
    tsx-ts-mode
    js-json-mode
    json-ts-mode
    yaml-mode
    yaml-ts-mode
    sh-mode) . my/lsp-maybe-ensure)

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
  ;; 显式声明常见服务器命令，保证 Mason 安装到 mason/bin/ 后能被 Eglot 正确调用。
  (dolist (entry '((java-mode . ("jdtls")) (java-ts-mode . ("jdtls"))
                   (python-mode . ("pyright-langserver" "--stdio"))
                   (python-ts-mode . ("pyright-langserver" "--stdio"))
                   (lua-mode . ("lua-language-server")) (lua-ts-mode . ("lua-language-server"))
                   (js-mode . ("typescript-language-server" "--stdio"))
                   (js-ts-mode . ("typescript-language-server" "--stdio"))
                   (typescript-mode . ("typescript-language-server" "--stdio"))
                   (typescript-ts-mode . ("typescript-language-server" "--stdio"))
                   (tsx-ts-mode . ("typescript-language-server" "--stdio"))
                   (js-json-mode . ("vscode-json-language-server" "--stdio"))
                   (json-ts-mode . ("vscode-json-language-server" "--stdio"))
                   (yaml-mode . ("yaml-language-server" "--stdio"))
                   (yaml-ts-mode . ("yaml-language-server" "--stdio"))
                   (sh-mode . ("bash-language-server" "start"))))
    (add-to-list 'eglot-server-programs entry))
  ;; 中文说明：Cape 可用时组合文件补全；否则使用 Eglot 原生补全，避免可选包影响 LSP。
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (setq-local completion-at-point-functions
                          (if (fboundp 'cape-super-capf)
                              (list (cape-super-capf #'eglot-completion-at-point
                                                    #'cape-file))
                            (list #'eglot-completion-at-point)))))
                                 
  ;; 保存文件时自动格式化 (可选)
  ;; (add-hook 'before-save-hook #'eglot-format-buffer)
  )

;; ============================================================================
;; 4. Outline / 代码结构大纲体系
;; ============================================================================

;; 方案 A: 实时搜索跳转的大纲 (结合已安装的 Consult)
;; 触发命令：`consult-imenu`

;; 方案 B: 侧边栏树状代码大纲 (Imenu-list)
;; 中文说明：大纲侧栏为可选界面；Consult Imenu 在该包不可用时仍可使用。
(condition-case err
    (use-package imenu-list
      :straight t
      :defer t
      :custom
      (imenu-list-auto-resize t)
      (imenu-list-focus-after-activation t))
  (error (message "imenu-list 未加载：%s" (error-message-string err))))

;; 方案 C: 在当前 frame 右侧用 Speedbar 显示当前文件的 Imenu 大纲。
(condition-case err
    (use-package sr-speedbar
      :straight (:host github :repo "emacsorphanage/sr-speedbar")
      :commands (sr-speedbar-open sr-speedbar-close sr-speedbar-toggle)
      :custom
      (sr-speedbar-right-side t)
      (sr-speedbar-default-width 36)
      (sr-speedbar-max-width 50)
      (sr-speedbar-auto-refresh t)
      ;; 保留普通窗口布局，不让 Speedbar 打开时删除其他窗口。
      (sr-speedbar-delete-windows nil)
      (speedbar-use-imenu-flag t))
  (error (message "sr-speedbar 未加载：%s" (error-message-string err))))

(defun my/sr-speedbar--expand-buffer-outline (source-buffer)
  "Show and expand SOURCE-BUFFER's Imenu outline in sr-speedbar."
  (when (and (buffer-live-p source-buffer)
             (buffer-file-name source-buffer)
             (buffer-live-p speedbar-buffer))
    (let ((source-name (buffer-name source-buffer)))
      (with-current-buffer speedbar-buffer
        (speedbar-change-initial-expansion-list "quick buffers")
        (speedbar-refresh)
        (goto-char (point-min))
        (catch 'expanded
          (while (not (eobp))
            (when (equal (speedbar-line-text) source-name)
              (speedbar-expand-line)
              (throw 'expanded t))
            (forward-line 1)))))))

(defun my/sr-speedbar-outline-toggle ()
  "Toggle sr-speedbar with the current file's outline expanded."
  (interactive)
  (require 'sr-speedbar)
  (if (sr-speedbar-exist-p)
      (sr-speedbar-close)
    (let ((source-buffer (current-buffer)))
      (sr-speedbar-open)
      (my/sr-speedbar--expand-buffer-outline source-buffer))))


(use-package treemacs
  :straight t
  :defer t
  :custom
  (treemacs-width 35)
  ;; 允许 C-c w r 中的窗口尺寸命令直接调整 Treemacs。
  (treemacs-width-is-initially-locked nil)
  ;; 避免 C-x o (other-window) 切换光标时误入侧边栏
 ;; (treemacs-is-never-other-window t)
)

(with-eval-after-load 'treemacs
  (defun my/treemacs--workspace-project-for-exact-path (path)
    "Return (WORKSPACE . PROJECT) whose project root is exactly PATH."
    (let ((canonical-path (-> path file-truename treemacs-canonical-path)))
      (catch 'found
        (dolist (workspace (treemacs-workspaces))
          (dolist (project (treemacs-workspace->projects workspace))
            (when (treemacs-is-path canonical-path :same-as
                                    (treemacs-project->path project))
              (throw 'found (cons workspace project))))))))

  (defun my/treemacs--unique-workspace-name (path)
    "Return an unused Treemacs workspace name derived from PATH."
    (let* ((base (file-name-nondirectory (directory-file-name path)))
           (candidate base)
           (index 2))
      (while (treemacs-find-workspace-by-name candidate)
        (setq candidate (format "%s (%d)" base index)
              index (1+ index)))
      candidate))

  (defun my/treemacs--add-overlap-in-separate-workspace (original path name)
    "Add overlapping PATH through ORIGINAL in its own Treemacs workspace."
    (if-let ((existing (my/treemacs--workspace-project-for-exact-path path)))
        (progn
          (unless (eq (car existing) (treemacs-current-workspace))
            (treemacs-do-switch-workspace (car existing)))
          `(success ,(cdr existing)))
      (let* ((previous-workspace (treemacs-current-workspace))
             (workspace-name (my/treemacs--unique-workspace-name path)))
        (pcase (treemacs-do-create-workspace workspace-name)
          (`(success ,workspace)
           (treemacs-do-switch-workspace workspace)
           (let ((result (funcall original path name)))
             (unless (eq (car-safe result) 'success)
               ;; 创建后的首次加入理论上不会失败；若失败则回滚空 workspace。
               (treemacs-do-switch-workspace previous-workspace)
               (treemacs-do-remove-workspace
                (treemacs-workspace->name workspace) nil))
             result))
          (result result)))))

  (defun my/treemacs-add-overlapping-projects (original path name)
    "Let ORIGINAL add PATH, isolating only parent/child overlaps by workspace."
    (let ((result (funcall original path name)))
      (pcase result
        (`(duplicate-project ,project)
         ;; 完全相同的根仍然按重复项目处理；只有父目录包含 PATH 时才分流。
         (if (treemacs-is-path
              (-> path file-truename treemacs-canonical-path)
              :same-as (treemacs-project->path project))
             result
           (my/treemacs--add-overlap-in-separate-workspace original path name)))
        (`(includes-project ,_)
         (my/treemacs--add-overlap-in-separate-workspace original path name))
        (_ result))))

  ;; Treemacs 以绝对路径作为节点唯一键，同一 workspace 不能安全容纳父子根。
  ;; 对添加入口做兼容：普通项目保持原行为，重叠项目自动进入独立 workspace。
  (advice-add #'treemacs-do-add-project-to-workspace
              :around #'my/treemacs-add-overlapping-projects)

  (defun my/treemacs-allow-delete-last-project
      (original project &optional _ignore-last-project-restriction ask-to-confirm)
    "Run ORIGINAL for PROJECT while permitting an empty Treemacs workspace."
    (funcall original project t ask-to-confirm))

  ;; 保留 Treemacs 原生的删除确认、视图刷新、缓存清理和持久化，只放宽
  ;; “workspace 至少保留一个项目”的限制。
  (advice-add #'treemacs-do-remove-project-from-workspace
              :around #'my/treemacs-allow-delete-last-project))

(use-package lsp-treemacs
  :straight t
  :after (treemacs)
  :config
  ;; 自动随当前编辑的 Buffer 同步高亮对应的符号
  (setq lsp-treemacs-sync-mode 1))

;; 挂载到 General.el 的代码大纲分组 (C-z o s)
(with-eval-after-load 'general
  (my-leader-def
    "d t" '("toggle treemacs file tree" . treemacs)
    "o s" '("toggle symbols tree sidebar" . lsp-treemacs-symbols)))

(use-package zoutline
  :straight (:host github :repo "abo-abo/zoutline")
  :defer t
  ;; zoutline 只提供 zo-* 导航命令，并没有 zoutline-mode。
  ;; 声明命令以生成可靠的延迟加载入口。
  :commands (zo-up zo-down zo-left zo-right))

;; 大纲显示相关操作统一放到 C-z o。
(with-eval-after-load 'general
  (my-leader-def
    "o u" '("outline parent" . zo-up)
    "o d" '("outline next heading" . zo-down)
    "o h" '("outline fold / parent" . zo-left)
    "o l" '("outline unfold / child" . zo-right)))

;; ============================================================================
;; 5. 配合 General.el 集中绑定 Leader 键
;; ============================================================================
(with-eval-after-load 'general
  (my-leader-def
    ;; LSP 相关功能 (Code / LSP)
    "ca"  '("code action / quick fix" . eglot-code-actions)
    "cr"  '("rename symbol" . eglot-rename)
    "cf"  '("format buffer/region" . eglot-format)
    "cq"  '("stop lsp server" . eglot-shutdown)

    ;; 代码跳转集中到 Code navigation 子菜单，给 Diagnostics 留出独立命名空间。
    "c g d" '("definition" . xref-find-definitions)
    "c g r" '("references" . xref-find-references)
    "c g h" '("hover documentation" . eldoc)

    ;; 代码大纲与导航 (Outline / Imenu)
    "oi"  '("jump to symbol (imenu)" . consult-imenu)
    "oI"  '("jump to symbol (all buffers)" . consult-imenu-multi)
    "ob"  '("toggle Speedbar outline" . my/sr-speedbar-outline-toggle)
    "ot"  '("toggle outline sidebar" . imenu-list-smart-toggle)))

(provide 'init-lsp)
;;; init-lsp.el ends here

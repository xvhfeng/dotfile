;;; init-lsp.el --- Eglot LSP、代码补全与结构大纲 -*- lexical-binding: t; -*-

(require 'seq)

(defun my/corfu-orderless-setup ()
  "Use Orderless matching only in Corfu completion buffers."
  (setq-local completion-styles '(orderless basic)))

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
      :hook (corfu-mode . my/corfu-orderless-setup)
      :init
      (global-corfu-mode 1)
      (corfu-popupinfo-mode 1))
  (error (message "Corfu 未加载：%s" (error-message-string err))))


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
    (sh-mode . "bash-language-server")
    ;; HTML 的传统、Tree-sitter 和模板模式都复用 Microsoft HTML LSP。
    (html-mode . "vscode-html-language-server")
    (html-ts-mode . "vscode-html-language-server")
    (mhtml-mode . "vscode-html-language-server")
    (mhtml-ts-mode . "vscode-html-language-server")
    (web-mode . "vscode-html-language-server"))
  "主模式与对应 LSP 可执行文件的映射；用于避免缺少服务器时影响编辑。")

;; 仅当对应服务器存在时启动 Eglot，缺失依赖只给出提示而不让打开文件报错。
(defun my/lsp-maybe-ensure ()
  "在当前主模式存在本地语言服务器时安全启动 Eglot。"
  (let ((server (alist-get major-mode my/lsp-server-commands)))
    (when (and server (executable-find server))
      (eglot-ensure))))

(defconst my/html-lsp-server-contact
  '("vscode-html-language-server" "--stdio"
    :initializationOptions (:provideFormatter t))
  "Eglot connection description for the Microsoft HTML language server.
The server deliberately disables its formatter unless `provideFormatter' is
explicitly true during initialization.")

(use-package eglot
  ;; Emacs 29+ 已内置 Eglot。必须显式关闭 Straight，避免它把旧版
  ;; project/xref/jsonrpc 一并加入 load-path，与当前 Emacs 的内置库冲突。
  :straight nil
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
    sh-mode
    html-mode
    html-ts-mode
    mhtml-mode
    mhtml-ts-mode
    web-mode) . my/lsp-maybe-ensure)

    :custom
  ;; 避免 LSP 频繁在 minibuffer 输出冗长的提示信息
  (eglot-ignored-server-capabilities '(:inlayHintProvider))
  ;; 禁用 Eglot 自动修改事件日志，提升高频输入性能
  (eglot-events-buffer-config '(:size 0 :format lisp))

  :config
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
  ;; HTML server 只接受 "html" 这个 LSP languageId；不能让 `web-mode'
  ;; 默认转换成 "web"，否则服务器虽启动却不会提供格式化能力。
  (add-to-list
   'eglot-server-programs
   `(((html-mode :language-id "html")
      (html-ts-mode :language-id "html")
      (mhtml-mode :language-id "html")
      (mhtml-ts-mode :language-id "html")
      (web-mode :language-id "html"))
     . ,my/html-lsp-server-contact))
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

(defun my/eglot-format (&optional _beg _end)
  "使用当前主模式的原生规则缩进整个 Buffer。
此命令保留原有的 `C-c c f' 入口，但不再请求 LSP 或外部格式化器；其
行为等价于 Vim 的 `gg=G'，不受选区、文件大小或 Eglot 状态影响。"
  (interactive)
  (save-restriction
    (widen)
    (indent-region (point-min) (point-max))))

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

;; 中文说明：Eglot 把 LSP `DocumentSymbol` 转为嵌套的 Imenu 索引，其中包含
;; “类型 → 方法/字段 → 内嵌类型”等父子关系。Imenu List 直接显示这棵原始树，
;; 不按 SymbolKind 重排为额外分类节点，避免破坏语言服务器给出的顺序和层级。

(defun my/treemacs-find-stable-python ()
  "Return a directly executable Python 3 binary for Treemacs helpers.
Prefer system package-manager binaries over version-manager shims because GUI
Emacs may find an asdf shim without having the `asdf' command in its PATH."
  (let ((candidates
         (append
          (when (eq system-type 'darwin)
            '("/opt/homebrew/bin/python3" "/usr/local/bin/python3"))
          '("/usr/bin/python3")
          (list (executable-find "python3")))))
    (when-let ((python
                (seq-find (lambda (candidate)
                            (and candidate (file-executable-p candidate)))
                          candidates)))
      (file-truename python))))

(use-package treemacs
  :straight t
  :defer t
  :custom
  ;; Treemacs 的 Git 状态和目录折叠脚本会异步启动 Python。不要使用
  ;; ~/.asdf/shims/python3：GUI Emacs 可能能找到 shim，却找不到 shim 依赖的 asdf。
  (treemacs-python-executable (my/treemacs-find-stable-python))
  (treemacs-persist-file (my/runtime-file "treemacs/persist"))
  (treemacs-last-error-persist-file
   (my/runtime-file "treemacs/persist-at-last-error"))
  (treemacs-width 35)
  ;; 允许 C-w r 中的窗口尺寸命令直接调整 Treemacs。
  (treemacs-width-is-initially-locked nil)
  ;; 避免 C-x o (other-window) 切换光标时误入侧边栏
 ;; (treemacs-is-never-other-window t)
)

;; 中文说明：Treemacs 仅负责稳定显示项目文件树；当前安装版本的“标签自动跟随”
;; 无法处理 Eglot Document Symbol 的整数位置，会在 C/clangd 中报 markerp 错误。
;; 代码大纲改由专门的 Imenu List 展示，避免让文件树功能影响 LSP 编辑。
(defun my/treemacs-show-current-file-outline ()
  "打开当前文件的 Imenu/LSP 代码大纲，不启用不兼容的 Treemacs 标签跟随。"
  (interactive)
  (if (require 'imenu-list nil t)
      (imenu-list-smart-toggle)
    ;; Imenu List 缺失时仍可使用 Emacs 内置 Imenu，不阻断代码跳转。
    (call-interactively #'imenu)))

(with-eval-after-load 'treemacs
  ;; 中文说明：关闭 Treemacs 的标签自动跟随。该第三方实现把 Eglot 返回的整数
  ;; 位置传给 `marker-position`，会持续产生 `wrong-type-argument markerp`。
  ;; 此设置不影响 Treemacs 文件树、项目管理、Flymake 或 Imenu List 代码大纲。
  (when (bound-and-true-p treemacs-tag-follow-mode)
    (treemacs-tag-follow-mode -1))
  ;; Treemacs 中用 C-c w 直接打开 workspace 菜单；原来的
  ;; C-c C-w 局部菜单移除，让位给全局独占的 Ace Window。
  ;; 把普通窗口菜单设为父 keymap：workspace 键优先，其余键继续可用。
  (set-keymap-parent treemacs-workspace-map my-window-map)
  ;; 小写 r 保留统一的“调整窗口大小”语义；Treemacs 重命名改用 R。
  (define-key treemacs-workspace-map (kbd "R") #'treemacs-rename-workspace)
  (define-key treemacs-workspace-map (kbd "r") nil)
  (define-key treemacs-mode-map (kbd "C-c w") treemacs-workspace-map)
  (define-key treemacs-mode-map (kbd "C-c C-w") nil)
  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements
      treemacs-mode-map
      "C-c w" "Treemacs workspaces / windows")
    (which-key-add-keymap-based-replacements
      treemacs-workspace-map
      "R" "rename workspace"))

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

;; 中文说明：lsp-treemacs 依赖 lsp-mode，与当前 Eglot 客户端不兼容；
;; C-c o s 改用稳定的 Imenu List 代码大纲，兼容 LSP、Tree-sitter 与普通 major mode。
(with-eval-after-load 'general
  (my-leader-def
    "d t" '("切换 Treemacs 文件树" . treemacs)
    "o s" '("显示当前文件大纲" . my/treemacs-show-current-file-outline)))

(use-package zoutline
  :straight (:host github :repo "abo-abo/zoutline")
  :defer t
  ;; zoutline 只提供 zo-* 导航命令，并没有 zoutline-mode。
  ;; 声明命令以生成可靠的延迟加载入口。
  :commands (zo-up zo-down zo-left zo-right))

;; 大纲显示相关操作统一放到 C-c o。
(with-eval-after-load 'general
  (my-leader-def
    "o u" '("大纲上级" . zo-up)
    "o d" '("下一个大纲标题" . zo-down)
    "o h" '("折叠或上级" . zo-left)
    "o l" '("展开或子级" . zo-right)))

;; ============================================================================
;; 5. 配合 General.el 集中绑定 Leader 键
;; ============================================================================
(with-eval-after-load 'general
  (my-leader-def
    ;; LSP 相关功能 (Code / LSP)
    "ca"  '("代码操作或快速修复" . eglot-code-actions)
    "cr"  '("重命名符号" . eglot-rename)
    "cf"  '("格式化缓冲区或区域" . my/eglot-format)
    "cq"  '("停止 LSP 服务器" . eglot-shutdown)

    ;; 代码跳转集中到 Code navigation 子菜单，给 Diagnostics 留出独立命名空间。
    "c g d" '("跳转到定义" . xref-find-definitions)
    "c g r" '("查找引用" . xref-find-references)
    "c g b" '("返回跳转位置" . xref-go-back)
    "c g f" '("前进跳转位置" . xref-go-forward)
    "c g h" '("显示光标处文档" . eldoc)

    ;; 代码大纲与导航 (Outline / Imenu)
    "oi"  '("跳转到当前文件符号" . consult-imenu)
    "oI"  '("跳转到全部缓冲区符号" . consult-imenu-multi)
    "ot"  '("切换大纲侧栏" . imenu-list-smart-toggle)))

(provide 'init-lsp)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - Eglot 为 lang/ 中配置的语言提供补全、跳转、重命名、格式化和 Flymake 诊断。
;; - `C-c c a/r/f/q'：代码动作、重命名、格式化、停止 LSP；`C-c c g d/r/b/f/h'：
;;   定义/引用/后退/前进/文档。
;; - `C-c o i/I' 搜索当前/全部 Buffer 的符号；`C-c o t' 打开 Imenu List 大纲。
;; - Treemacs 只负责文件树，不再承载代码大纲。
;; - `C-c o u/d/h/l' 在 zoutline 中到父级/下一标题/折叠/展开；`C-c d t' 开关文件树。
;; - Treemacs 允许重叠目录进入独立 workspace，也允许删除最后一个项目；窗口宽度手工调整。
;; - Treemacs Buffer 中 `C-c w' 为 workspace/窗口菜单；`C-c C-w' 专用于 Ace Window。
;; - Treemacs 中 `C-c w r' 调整窗口大小，`C-c w R' 重命名 Workspace。
;; - 其他 workspace 键 a/d/e/f/n/s 优先；需要同名窗口命令时使用 `C-w'。
;; - Treemacs 的异步脚本固定使用真实 Python 3，避免 GUI PATH 下的 asdf shim 执行失败。
;; - LSP 启动失败先确认 `C-c x m' 中对应服务器已安装，再查看 *eglot events*。
;;; init-lsp.el ends here

;;; init-mason.el --- Dedicated external dependencies manager -*- lexical-binding: t; -*-

;; ============================================================================
;; 1. 自动同步终端环境变量 PATH
;; 说明：确保在 GUI 环境（如 macOS APP 或 Linux GUI）启动时，
;; Emacs 能正常读取到系统已安装的 node, python, go, cargo 等工具链路径。
;; ============================================================================
(use-package exec-path-from-shell
  :straight t
  :if (memq window-system '(mac ns x))
  :config
  (exec-path-from-shell-initialize))

;; ============================================================================
;; 2. Mason.el 配置 (自动下载与注册第三方二进制程序)
;; 说明：所有由 Mason 安装的语言服务器和格式化程序均放在 runtimes/mason/bin/，
;; 不写入系统目录；即使 Mason 尚未安装，也会预先把该目录加入当前 Emacs 的 PATH。
;; ============================================================================
(defvar my/mason-runtime-directory
  (file-name-as-directory (my/runtime-file "mason/"))
  "Mason 的运行时根目录。")

(defvar my/local-bin-directory
  (expand-file-name "bin/" my/mason-runtime-directory)
  "Mason 管理的语言服务器可执行文件目录。")

;; 创建本地二进制目录并同步到 Emacs/子进程 PATH，保证 Eglot 可找到服务器。
(make-directory my/local-bin-directory t)
(add-to-list 'exec-path my/local-bin-directory)
(setenv "PATH" (concat my/local-bin-directory path-separator (getenv "PATH")))

(defun my/mason-install-missing-packages ()
  "启动后自动安装 `mason-ensure-packages' 中尚未安装的工具。"
  (interactive)
  (require 'mason)
  (mason-ensure
   (lambda ()
     (dolist (package mason-ensure-packages)
       (unless (mason-installed-p package)
         (condition-case err
             (mason-install package)
           (error (message "Mason 安装 %s 失败：%s"
                           package (error-message-string err)))))))))

(use-package mason
  ;; 中文说明：Mason 的当前上游仓库归属 mason-org，避免使用已失效的旧仓库地址。
  :straight (:host github :repo "mason-org/mason.el")
  :init
  ;; 必须在加载 Mason 前设置，否则它会使用 user-emacs-directory/mason。
  (setq mason-dir my/mason-runtime-directory)
  :config
  ;; Mason 的后台 Emacs 用 -Q 启动，不能依赖 GUI 会话的 Shell 初始化。
  ;; 明确指定本机已验证的 Homebrew 工具，避免 Python/Node/Lua 查找失败。
  (setq mason-command-overrides
        '(("python" . "/opt/homebrew/bin/python3")
          ("python3" . "/opt/homebrew/bin/python3")
          ("node" . "/opt/homebrew/bin/node")
          ("npm" . "/opt/homebrew/bin/npm")
          ("lua" . "/opt/homebrew/bin/lua")
          ("luarocks" . "/opt/homebrew/bin/luarocks")))
  ;; 在当前 Emacs 中同步目标平台，避免后台目标探测尚未完成时出现 target=nil。
  (setq mason--target (mason--get-target))
  ;; --------------------------------------------------------------------------
  ;; 在此集中声明你需要 Emacs 自动下载管理的第三方程序列表
  ;; --------------------------------------------------------------------------
  (setq mason-ensure-packages
        '(
          ;; --- LSP 语言服务器 (Language Servers) ---
          "clangd"                ; C / C++ 语言服务器
          "pyright"               ; Python 语言服务器
          "jdtls"                 ; Java 语言服务器 (Eclipse JDT)
          "lua-language-server"   ; Lua 语言服务器
          "yaml-language-server"  ; YAML 语言服务器
          "lemminx"               ; XML 语言服务器
          "bash-language-server"  ; Shell / Bash 语言服务器
          "typescript-language-server" ; JavaScript / TypeScript 语言服务器
          "json-lsp"              ; JSON 语言服务器（可执行文件名仍为 vscode-json-language-server）
          "html-lsp"              ; HTML 语言服务器（vscode-html-language-server）

          ;; --- 代码格式化工具 (Formatters) ---
          "clang-format"          ; C / C++ 代码格式化
          "black"                 ; Python 代码格式化
          "prettier"              ; YAML / JSON / Web 常用格式化

          ;; --- 代码静态检查工具 (Linters / Diagnostics) ---
          "flake8"                ; Python 静态检查
          "luacheck"              ; Lua 静态检查
          ))

  )

;; Mason 注册表准备就绪后自动补齐工具；失败仅记录该包，不会阻断启动。
(with-eval-after-load 'mason
  (my/mason-install-missing-packages))

;; ============================================================================
;; 3. Mason 管理界面与常用快捷操作 (交互入口)
;; ============================================================================
;; 中文说明：Mason 属于工具操作，统一放在 C-c x m。
(with-eval-after-load 'general
  (my-leader-def
    "x m" '("Mason 工具管理器" . mason-manager)))

(provide 'init-mason)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - Mason 把语言服务器、格式化器和检查器安装到 `runtimes/mason/'，不修改系统目录。
;; - `C-c x m' 打开 Mason 管理器，查看、安装、更新或删除外部工具。
;; - 启动时自动安装缺失工具；也可手动运行 `M-x my/mason-install-missing-packages'。
;; - GUI Emacs 会同步 Shell PATH，并把 `runtimes/mason/bin/' 放到 Eglot 可搜索的最前面。
;; - 下载失败时先在 Mason 管理器重试，并检查网络、GitHub 访问和 *Messages* 的具体错误。
;; - 增减工具只需编辑 `mason-ensure-packages'；调试适配器由 init-debug.el 单独管理。
;;; init-mason.el ends here

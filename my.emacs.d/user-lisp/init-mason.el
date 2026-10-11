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
;; 说明：所有由 Mason 安装的语言服务器和格式化程序均放在配置根目录的 bin/，
;; 不写入系统目录；即使 Mason 尚未安装，也会预先把该目录加入当前 Emacs 的 PATH。
;; ============================================================================
(defvar my/local-bin-directory
  (expand-file-name "bin/" user-emacs-directory)
  "配置根目录下保存语言服务器等本地可执行文件的目录。")

;; 创建本地二进制目录并同步到 Emacs/子进程 PATH，保证 Eglot 可找到服务器。
(make-directory my/local-bin-directory t)
(add-to-list 'exec-path my/local-bin-directory)
(setenv "PATH" (concat my/local-bin-directory path-separator (getenv "PATH")))

(use-package mason
  ;; 中文说明：Mason 的当前上游仓库归属 mason-org，避免使用已失效的旧仓库地址。
  :straight (:host github :repo "mason-org/mason.el")
  :config
  ;; 兼容 Mason 的不同版本：包加载完成后再改写其二进制目录，确保变量已定义。
  (when (boundp 'mason-bin-dir)
    (setq mason-bin-dir my/local-bin-directory))
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
          "vscode-json-language-server" ; JSON 语言服务器

          ;; --- 代码格式化工具 (Formatters) ---
          "clang-format"          ; C / C++ 代码格式化
          "black"                 ; Python 代码格式化
          "prettier"              ; YAML / JSON / Web 常用格式化

          ;; --- 代码静态检查工具 (Linters / Diagnostics) ---
          "flake8"                ; Python 静态检查
          "luacheck"              ; Lua 静态检查
          ))

  ;; 先初始化 Mason 的运行环境，再仅安装尚未安装的工具；安装失败不会阻断 Emacs。
  (when (fboundp 'mason-setup)
    (mason-setup))
  (when (and (fboundp 'mason-install) (fboundp 'mason-installed-p))
    (dolist (package mason-ensure-packages)
      (unless (mason-installed-p package)
        (condition-case err
            (mason-install package)
          (error (message "Mason 安装 %s 失败：%s" package (error-message-string err))))))))

;; ============================================================================
;; 3. Mason 管理界面与常用快捷操作 (交互入口)
;; ============================================================================
;; 中文说明：Mason 当前的管理命令为 mason-manager；C-c m 打开本地工具管理界面。
(with-eval-after-load 'mason
  (global-set-key (kbd "C-c m") #'mason-manager))

(provide 'init-mason)
;;; init-mason.el ends here

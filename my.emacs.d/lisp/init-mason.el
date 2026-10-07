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
;; 说明：所有下载的程序均存储在 ~/.emacs.d/mason/ bin 目录下，不污染系统全局环境。
;; ============================================================================
(use-package mason
  :straight (:host github :repo "stevearc/mason.el")
  :init
  ;; 核心：将 Mason 的二进制安装目录追加到 Emacs 的 exec-path 和 $PATH 中，
  ;; 确保 Eglot / Flymake 等内置插件能无缝识别并直接调用这些第三方程序。
  (mason-setup-exec-path)
  :config
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
          "sqls"                  ; SQL 语言服务器

          ;; --- 代码格式化工具 (Formatters) ---
          "clang-format"          ; C / C++ 代码格式化
          "black"                 ; Python 代码格式化
          "prettier"              ; YAML / JSON / Web 常用格式化

          ;; --- 代码静态检查工具 (Linters / Diagnostics) ---
          "flake8"                ; Python 静态检查
          "luacheck"              ; Lua 静态检查
          ))

  ;; 启动 Emacs 时，自动检查上方列表，若缺少某个工具则自动在后台进行安装
  (mason-ensure))

;; ============================================================================
;; 3. Mason 管理界面与常用快捷操作 (交互入口)
;; ============================================================================
;; 开启图形化管理界面，输入 M-x mason 即可查看、安装、升级或卸载工具包
(global-set-key (kbd "C-c m") #'mason)

(provide 'init-mason)
;;; init-mason.el ends here
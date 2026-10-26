;;; init-mason.el --- Dedicated external dependencies manager -*- lexical-binding: t; -*-

;; ============================================================================
;; 1. 自动同步终端环境变量 PATH
;; 说明：确保在 GUI 环境（如 macOS APP 或 Linux GUI）启动时，
;; Emacs 能正常读取到系统已安装的 node, python, go, cargo 等工具链路径。
;; ============================================================================
(use-package exec-path-from-shell
  :straight t
  :if (memq window-system '(mac ns x))
  ;; 全局启用了 `use-package-always-defer'。这里必须立即同步 GUI Emacs 的
  ;; PATH，否则后面 Mason 虽然加载了，仍可能找不到 Homebrew/asdf 工具。
  :demand t
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

(defconst my/mason-tool-registry
  '((language-server
     ("clangd" . "C / C++ 语言服务器")
     ("pyright" . "Python 语言服务器")
     ("gopls" . "Go 语言服务器")
     ("jdtls" . "Java 语言服务器")
     ("lua-language-server" . "Lua 语言服务器")
     ("yaml-language-server" . "YAML 语言服务器")
     ("lemminx" . "XML 语言服务器")
     ("bash-language-server" . "Bash 语言服务器")
     ("typescript-language-server" . "JavaScript / TypeScript 语言服务器")
     ("json-lsp" . "JSON 语言服务器")
     ("html-lsp" . "HTML 语言服务器"))
    (formatter
     ("clang-format" . "C / C++ 格式化")
     ("black" . "Python 格式化")
     ("prettier" . "Web / JSON / YAML 格式化"))
    (linter
     ("flake8" . "Python 静态检查")
     ("luacheck" . "Lua 静态检查"))
    (debug-adapter
     ("codelldb" . "C / C++ 调试适配器")
     ("delve" . "Go 调试适配器")
     ("debugpy" . "Python 调试适配器")
     ("js-debug-adapter" . "JavaScript / TypeScript 调试适配器")
     ("java-debug-adapter" . "Java 调试适配器")
     ("local-lua-debugger-vscode" . "Lua 调试适配器")
     ("bash-debug-adapter" . "Bash 调试适配器")))
  "Mason 自动管理的工具注册表。
共 23 项：16 个语言、格式化及检查工具，7 个调试适配器。")

(defun my/mason-packages-in-category (category)
  "返回 `my/mason-tool-registry' 中 CATEGORY 对应的包名。"
  (mapcar #'car (alist-get category my/mason-tool-registry)))

(defconst my/mason-managed-packages
  (apply #'append
         (mapcar (lambda (entry)
                   (mapcar #'car (cdr entry)))
                 my/mason-tool-registry))
  "从 `my/mason-tool-registry' 生成的全部 Mason 包名。")

(defvar my/mason-bootstrap-started nil
  "非 nil 表示本次 Emacs 会话已经启动过 Mason 自动安装。")

(defvar my/mason-last-install-result nil
  "最近一次自动安装的状态，格式为 (:status STATUS :total N :remaining N :failed LIST)。")

;; 创建本地二进制目录并同步到 Emacs/子进程 PATH，保证 Eglot 可找到服务器。
(make-directory my/local-bin-directory t)
(add-to-list 'exec-path my/local-bin-directory)
(setenv "PATH" (concat my/local-bin-directory path-separator (getenv "PATH")))

(defun my/mason-ensure-python-command ()
  "Provide Mason's PyPI installers with a python command when only python3 exists."
  (let* ((shim (expand-file-name "python" my/local-bin-directory))
         (python3 (or (executable-find "python3")
                      (and (file-executable-p "/opt/homebrew/bin/python3")
                           "/opt/homebrew/bin/python3"))))
    (when (and python3 (not (file-executable-p shim)))
      (make-symbolic-link python3 shim t))))

(my/mason-ensure-python-command)

(defun my/mason--record-install-result (package success)
  "记录 PACKAGE 的安装结果 SUCCESS，并在整批完成时输出汇总。"
  (unless success
    (setf (plist-get my/mason-last-install-result :failed)
          (cons package (plist-get my/mason-last-install-result :failed))))
  (cl-decf (plist-get my/mason-last-install-result :remaining))
  (when (zerop (plist-get my/mason-last-install-result :remaining))
    (let ((failed (nreverse (plist-get my/mason-last-install-result :failed))))
      (setf (plist-get my/mason-last-install-result :status)
            (if failed 'failed 'complete))
      (if failed
          (message "Mason：自动安装结束，失败 %d 项：%s"
                   (length failed) (mapconcat #'identity failed ", "))
        (message "Mason：%d 个注册工具自动安装完成"
                 (plist-get my/mason-last-install-result :total))))))

(defun my/mason-install-packages (packages)
  "准备 Mason 注册表并安装 PACKAGES 中所有缺失的工具。"
  (require 'mason)
  (mason-ensure
   (lambda ()
     (let ((missing (seq-filter (lambda (package)
                                  (not (mason-installed-p package)))
                                packages)))
       (if (null missing)
           (progn
             (setq my/mason-last-install-result
                   (list :status 'complete :total (length packages)
                         :remaining 0 :failed nil))
             (message "Mason：注册的 %d 个工具均已安装" (length packages)))
         (setq my/mason-last-install-result
               (list :status 'installing :total (length missing)
                     :remaining (length missing) :failed nil))
         (message "Mason：开始自动安装 %d 个缺失工具：%s"
                  (length missing) (mapconcat #'identity missing ", "))
         (dolist (package missing)
           ;; 每个异步回调必须捕获自己这一轮的包名，不能共享 dolist 变量。
           (let ((package-name package))
             (condition-case err
                 (mason-install
                  package-name nil nil
                  (lambda (success)
                    (my/mason--record-install-result package-name success)))
               (error
                (message "Mason 安装 %s 失败：%s"
                         package-name (error-message-string err))
                (my/mason--record-install-result package-name nil))))))))))

(defun my/mason-install-missing-packages ()
  "安装 `my/mason-tool-registry' 中尚未安装的全部工具。"
  (interactive)
  (my/mason-install-packages my/mason-managed-packages))

(defun my/mason-command-overrides-from-path ()
  "Return Mason command overrides resolved from this machine's PATH.
Only include commands that actually exist, so the same configuration works on
Apple Silicon, Intel macOS, Linux, Homebrew, and version-manager installs."
  (delq nil
        (mapcar (lambda (command)
                  (when-let ((executable (executable-find command)))
                    (cons command executable)))
                '("python" "python3" "node" "npm" "lua" "luarocks"))))

(defun my/mason-auto-install-packages ()
  "首次初始化 Mason 时自动安装注册的全部工具。
批处理任务只验证配置，不访问网络；同一 Emacs 会话最多自动启动一次。"
  (unless (or noninteractive my/mason-bootstrap-started)
    (setq my/mason-bootstrap-started t)
    (my/mason-install-missing-packages)))

(use-package mason
  ;; 中文说明：Mason 的当前上游仓库归属 mason-org，避免使用已失效的旧仓库地址。
  :straight (:host github :repo "mason-org/mason.el")
  ;; 没有命令、hook 或 mode 会主动触发 Mason。全局延迟加载开启时若不
  ;; demand，下面的 :config 和自动安装回调永远不会执行。
  :demand t
  :init
  ;; 必须在加载 Mason 前设置，否则它会使用 user-emacs-directory/mason。
  (setq mason-dir my/mason-runtime-directory)
  :config
  ;; 使用同步后的 PATH 解析真实位置，不把配置锁死在 /opt/homebrew。
  (setq mason-command-overrides (my/mason-command-overrides-from-path))
  ;; 在当前 Emacs 中同步目标平台，避免后台目标探测尚未完成时出现 target=nil。
  (setq mason--target (mason--get-target))
  ;; Mason 插件加载完毕后，直接根据唯一注册表准备环境并安装缺失项。
  ;; 每次启动都会检查，只有第一次或注册表新增工具时才发生实际下载。
  (setq mason-ensure-packages (copy-sequence my/mason-managed-packages))
  (my/mason-auto-install-packages))

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
;; - Mason 首次初始化时自动安装 23 个注册工具；以后只补装新增或缺失项。
;; - 注册表是 `my/mason-tool-registry'；也可手动运行 `M-x my/mason-install-missing-packages'。
;; - GUI Emacs 会同步 Shell PATH，并把 `runtimes/mason/bin/' 放到 Eglot 可搜索的最前面。
;; - 下载失败时先在 Mason 管理器重试，并检查网络、GitHub 访问和 *Messages* 的具体错误。
;; - 增减工具只编辑 `my/mason-tool-registry'，不要在其他模块另起自动安装请求。
;;; init-mason.el ends here

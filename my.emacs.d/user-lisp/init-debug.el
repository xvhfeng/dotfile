;;; init-debug.el --- Unified debugging for configured languages -*- lexical-binding: t; -*-

;; Dape 是独立于 LSP 客户端的 DAP 前端，因此可以和当前 Eglot 配置配合使用。
;; 调试器由 Mason 安装在本配置目录内，不污染系统工具链。

(defconst my/debug-mason-packages
  (my/mason-packages-in-category 'debug-adapter)
  "从 Mason 中央注册表读取的 Debug Adapter 列表。")

(defun my/debug-install-adapters ()
  "安装 `my/debug-mason-packages' 中尚未安装的调试适配器。"
  (interactive)
  (my/mason-install-packages my/debug-mason-packages))

(defun my/debug-mason-file (&rest parts)
  "返回 Mason 目录下由 PARTS 组成的绝对路径。"
  (let ((path (my/runtime-file "mason/")))
    (dolist (part parts path)
      (setq path (expand-file-name part (file-name-as-directory path))))))

(defun my/debug--set-dape-config (name &rest properties)
  "把 PROPERTIES 写入 `dape-configs' 中名为 NAME 的配置。"
  (when-let ((cell (assq name dape-configs)))
    (while properties
      (setcdr cell (plist-put (cdr cell) (pop properties) (pop properties))))))

(defun my/debug-configure-dape ()
  "让 Dape 使用 Mason 安装的各语言 Debug Adapter。"
  (let ((bash-extension
         (my/debug-mason-file "packages/bash-debug-adapter/extension/"))
        (js-server
         (my/debug-mason-file
          "packages/js-debug-adapter/js-debug/src/dapDebugServer.js"))
        (lua-root
         (my/debug-mason-file "share/local-lua-debugger-vscode/")))
    ;; Python：Mason 的 wrapper 已经选中了自带 debugpy 的 Python 环境。
    (dolist (name '(debugpy debugpy-module))
      (my/debug--set-dape-config
       name
       'ensure #'dape-ensure-command
       'command "debugpy-adapter"
       'command-args '("--host" "127.0.0.1" "--port" :autoport)))

    ;; JavaScript / TypeScript：所有入口共用 Mason 的 js-debug server。
    (dolist (name '(js-debug-node js-debug-ts-node js-debug-tsx
                    js-debug-node-attach js-debug-chrome))
      (my/debug--set-dape-config
       name 'command-args (list js-server :autoport)))
    ;; Node 24+ 可运行可擦除类型的 .ts，但不能直接执行含 JSX 的 .tsx。
    (my/debug--set-dape-config
     'js-debug-node 'modes
     '(js-mode js-ts-mode typescript-mode typescript-ts-mode))
    (my/debug--set-dape-config
     'js-debug-tsx 'modes
     '(typescript-mode typescript-ts-mode tsx-ts-mode))

    ;; Bash：除 adapter 外还要告诉它 bashdb 运行库的位置。
    (my/debug--set-dape-config
     'bash-debug
     'command-args
     (list (expand-file-name "out/bashDebug.js" bash-extension))
     'fn
     (let ((bashdb-dir (expand-file-name "bashdb_dir/" bash-extension)))
       (lambda (config)
         (thread-first config
           (plist-put :pathBashdbLib bashdb-dir)
           (plist-put :pathBash (expand-file-name "bashdb" bashdb-dir))
           (plist-put :env `(:BASHDB_HOME ,bashdb-dir
                             . ,(plist-get config :env)))))))

    ;; CodeLLDB 比 macOS 上未签名的系统 GDB 更稳定。
    (add-to-list
     'dape-configs
     '(codelldb
       modes (c-mode c-ts-mode c++-mode c++-ts-mode)
       ensure dape-ensure-command
       command-cwd dape-command-cwd
       command "codelldb"
       command-args ("--port" :autoport)
       port :autoport
       :type "lldb"
       :request "launch"
       :cwd dape-cwd
       :program "a.out"
       :args []
       :stopOnEntry nil))

    ;; Local Lua Debugger 通过 stdio 与 Dape 通信。
    (add-to-list
     'dape-configs
     `(lua-local
       modes (lua-mode lua-ts-mode)
       ensure dape-ensure-command
       command-cwd dape-command-cwd
       command "node"
       command-args (,(expand-file-name "extension/debugAdapter.js" lua-root))
       :type "lua-local"
       :request "launch"
       :cwd dape-cwd
       :program (:lua "lua" :file dape-buffer-default)
       :extensionPath ,(directory-file-name lua-root)
       :args []
       :stopOnEntry nil))))

(use-package dape
  :straight (:host github :repo "svaante/dape")
  :commands (dape dape-breakpoint-toggle dape-continue dape-next
                  dape-step-in dape-step-out dape-pause dape-restart dape-quit
                  dape-info dape-repl dape-evaluate-expression dape-watch-dwim
                  dape-breakpoint-log dape-breakpoint-expression
                  dape-breakpoint-hits dape-breakpoint-remove-all)
  :init
  ;; Dape 自带的 C-x C-a 前缀与本配置的 General 体系重复，统一只保留 Leader。
  (setq dape-key-prefix nil
        ;; 断点状态属于运行时数据，不应写到配置源码根目录。
        dape-default-breakpoints-file (my/runtime-file "dape/breakpoints"))
  (make-directory (file-name-directory dape-default-breakpoints-file) t)
  :config
  (setq dape-buffer-window-arrangement 'right)
  (my/debug-configure-dape)
  ;; 保存断点；重新打开 Emacs 后仍可继续使用。
  (add-hook 'kill-emacs-hook #'dape-breakpoint-save)
  (add-hook 'after-init-hook #'dape-breakpoint-load)
  (dape-breakpoint-global-mode 1))

(with-eval-after-load 'general
  (my-leader-def
    ;; 会话生命周期。
    "c D s s" '("启动或选择调试器" . dape)
    "c D s r" '("重启会话" . dape-restart)
    "c D s q" '("退出并清理" . dape-quit)
    ;; 断点管理。
    "c D b b" '("切换断点" . dape-breakpoint-toggle)
    "c D b l" '("日志断点" . dape-breakpoint-log)
    "c D b c" '("条件断点" . dape-breakpoint-expression)
    "c D b h" '("断点命中次数" . dape-breakpoint-hits)
    "c D b a" '("移除全部断点" . dape-breakpoint-remove-all)
    ;; 运行和单步。
    "c D x c" '("继续运行" . dape-continue)
    "c D x p" '("暂停" . dape-pause)
    "c D x n" '("单步跳过" . dape-next)
    "c D x i" '("单步进入" . dape-step-in)
    "c D x o" '("单步跳出" . dape-step-out)
    ;; 变量和表达式检查。
    "c D i e" '("求值表达式" . dape-evaluate-expression)
    "c D i v" '("调试信息" . dape-info)
    "c D i r" '("调试 REPL" . dape-repl)
    "c D i w" '("监视表达式" . dape-watch-dwim)
    "c D m" '("安装调试适配器" . my/debug-install-adapters)
    ;; Emacs Lisp 不使用 DAP；用 Emacs 原生 Edebug 在同一菜单下调试。
    "c D E d" '("插桩当前函数" . edebug-defun)
    "c D E e" '("切换遇错调试" . toggle-debug-on-error)))

;; s s：启动/选择调试器
;; s r：重新启动
;; s q：停止并清理
;; b b：切换断点
;; b c：条件断点
;; b l：日志断点
;; x c：继续运行
;; x p：暂停
;; x n：单步跳过
;; x i：进入函数
;; x o：跳出函数
;; i e：计算表达式
;; i v：显示变量和调用栈
;; i r：调试 REPL
;; i w：监视表达式
;; E d：调试当前 Elisp 函数
;; m：补装缺失的调试适配器


(provide 'init-debug)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 调试统一位于 `C-c c D'；支持 C/C++、Python、JS/TS、Java、Lua、Bash 和 Emacs Lisp。
;; - 会话 `s s/r/q'：启动或选择/重启/退出；断点 `b b/l/c/h/a'：普通/日志/条件/次数/清空。
;; - 执行 `x c/p/n/i/o'：继续/暂停/跳过/进入/跳出；检查 `i e/v/r/w'：求值/信息/REPL/监视。
;; - `C-c c D m' 补装调试适配器；它们由 Mason 保存在本配置目录内。
;; - C/C++ 默认调试当前目录的 `a.out'；开始调试时可在 Dape 配置中修改程序和参数。
;; - Emacs Lisp 用 `C-c c D E d/e' instrument 当前函数/切换出错即调试，不经过 DAP。
;;; init-debug.el ends here

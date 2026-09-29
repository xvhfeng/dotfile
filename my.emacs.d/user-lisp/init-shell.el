;;; -*- lexical-binding: t; -*-

;; ----------------------------------------------------------------------------
;; 同步 macOS 系统 Bash/Shell 环境变量到 Emacs
;; ----------------------------------------------------------------------------
(use-package exec-path-from-shell
  :straight (:host github :repo "purcell/exec-path-from-shell")
  ;; 仅在 macOS (darwin) 或 Linux GUI 界面下启用
  :if (memq window-system '(mac ns x))
  :demand t
  :config
  ;; 1. 显式指定使用 /bin/bash 作为环境变量获取源
  ;; （如果你的默认 Shell 是 Bash，推荐加上这两行；若用 Zsh 可保留默认）
  (setq exec-path-from-shell-shell-name "/bin/bash")
  (setq exec-path-from-shell-arguments '("-l" "-i")) ; 以 Login + Interactive 方式启动 Bash

  ;; 2. 指定需要从 Bash 中同步导入的环境变量列表
  (setq exec-path-from-shell-variables
        '("PATH"            ; 可执行文件路径
          "MANPATH"         ; Help/Man 手册路径
          "GOPATH"          ; Go 语言路径 (如有)
          "GOROOT"          ; Go 安装路径 (如有)
          "PYTHONPATH"      ; Python 模块路径 (如有)
          "NVM_DIR"         ; Node/NVM 路径 (如有)
          "WORKON_HOME"     ; Python Virtualenv 路径 (如有)
          "JAVA_HOME"       ; Java 路径 (如有)
          "LANG"            ; 语言编码
          "LC_ALL"))

  ;; 3. 执行同步
  (exec-path-from-shell-initialize))

(provide 'init-shell)

;;; init-syspackages.el --- System package manager integration (Homebrew) -*- lexical-binding: t; -*-

;; ============================================================================
;; 1. system-packages: Emacs 接入系统包管理器 (Brew/Apt/Pacman)
;; ============================================================================
(use-package system-packages
  :straight t
  :custom
  ;; 显式指定系统包管理器为 brew (通常会自动识别，也可手动指定)
  (system-packages-packagemanager 'brew)
  ;; 安装时不弹出确认提示框，直接静默安装
  (system-packages-use-sudo nil))

;; ============================================================================
;; 2. use-package-ensure-system-package: 声明式自动安装 Brew 依赖
;; ============================================================================
;; 引入此扩展后，use-package 会多出一个 `:ensure-system-package` 关键字
(use-package use-package-ensure-system-package
  :straight t)

;; ============================================================================
;; 3. 集中声明你的 Emacs 依赖的 Homebrew 软件列表
;; ============================================================================
;; 示例 1: 确保安装了 consult-ripgrep / consult-find 强依赖的高速 CLI 工具
(use-package consult
  :ensure-system-package
  ((rg . "brew install ripgrep")
   (fd . "brew install fd")))

;; 示例 2: 确保安装了代码版本控制与 Git 工具
(use-package magit
  :ensure-system-package
  ((git . "brew install git")
   (delta . "brew install git-delta")))

;; 示例 3: 如果某些软件不绑定具体的 Elisp 插件，可以写一个通用的批量检查函数
(defvar my/sys-brew-packages
  '("ripgrep" "fd" "cmake" "ninja" "gnupg" "tree-sitter")
  "List of Homebrew formulaes required by Emacs.")

(defun my/ensure-brew-packages ()
  "Ensure all required Homebrew packages are installed."
  (interactive)
  (when (executable-find "brew")
    (dolist (pkg my/sys-brew-packages)
      (unless (system-packages-package-installed-p pkg)
        (message "Installing System Package via Brew: %s..." pkg)
        (system-packages-install pkg)))))

;; 在 Emacs 启动完毕后检查 Brew 依赖 (可选，解除注释即可启用)
;; (add-hook 'emacs-startup-hook #'my/ensure-brew-packages)

;; ============================================================================
;; 4. 配合 General.el 集中绑定快捷键
;; ============================================================================
(with-eval-after-load 'general
  (my-leader-def
    "h b" '(:ignore t :which-key "Homebrew / System Packages")
    "h b i" '(system-packages-install :which-key "brew install package")
    "h b u" '(system-packages-update  :which-key "brew update & upgrade")
    "h b s" '(system-packages-search  :which-key "search brew packages")))

(provide 'init-syspackages)
;;; init-syspackages.el ends here
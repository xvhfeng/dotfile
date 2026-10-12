;;; lang-python.el --- Python configuration with python-ts-mode and Eglot -*- lexical-binding: t; -*-

;; 中文说明：优先使用本地 bin/ 中由 Mason 管理的 pyright，不改动系统 Python 环境。
(use-package python
  :straight nil
  :mode ("\\.py\\'" . python-ts-mode)
  :hook (python-ts-mode . my/lsp-maybe-ensure)
  :config
  ;; 设置缩进为 4 个空格
  (setq python-indent-offset 4)
  ;; 配合 Eglot 优化 Python 的交互体验
  (setq python-shell-interpreter "python3"))

(provide 'lang-python)
;;; lang-python.el ends here

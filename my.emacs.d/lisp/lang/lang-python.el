;;; lang-python.el --- Python configuration with python-ts-mode and Eglot -*- lexical-binding: t; -*-

;;依赖外部 LSP 服务器：pyright 或 pylsp（推荐通过 pip install pyright 安装）。
(use-package python
  :ensure nil
  :mode ("\\.py\\'" . python-ts-mode)
  :hook (python-ts-mode . eglot-ensure)
  :config
  ;; 设置缩进为 4 个空格
  (setq python-indent-offset 4)
  ;; 配合 Eglot 优化 Python 的交互体验
  (setq python-shell-interpreter "python3"))

(provide 'lang-python)
;;; lang-python.el ends here
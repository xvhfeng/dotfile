;;; lang-lua.el --- Lua configuration with lua-ts-mode and Eglot -*- lexical-binding: t; -*-

;;  依赖外部 LSP 服务器：lua-language-server

(use-package lua-ts-mode
  :ensure nil
  :mode "\\.lua\\'"
  :hook (lua-ts-mode . eglot-ensure)
  :config
  (setq lua-ts-indent-offset 2))

(provide 'lang-lua)
;;; lang-lua.el ends here
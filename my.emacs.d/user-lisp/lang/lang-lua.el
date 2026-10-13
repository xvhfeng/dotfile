;;; lang-lua.el --- Lua configuration with lua-ts-mode and Eglot -*- lexical-binding: t; -*-

;; 中文说明：使用本地 bin/ 中由 Mason 管理的 lua-language-server，未安装时静默回退。

(use-package lua-mode
  :straight t
  :mode "\\.lua\\'"
  :hook ((lua-mode lua-ts-mode) . my/lsp-maybe-ensure)
  :config
  (setq lua-indent-level 2
        lua-ts-indent-offset 2))

(provide 'lang-lua)
;;; lang-lua.el ends here

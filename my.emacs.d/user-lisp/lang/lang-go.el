;;; lang-go.el --- Go source highlighting and fallback mode -*- lexical-binding: t; -*-

;; go-mode 由 init.el 在语言模块编译前安装；缺少 grammar 时提供高亮回退。
;; grammar 就绪后由全局 treesit-auto 将它升级到内置 go-ts-mode。
(add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode))

(provide 'lang-go)
;;; lang-go.el ends here

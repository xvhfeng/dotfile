;;; lang-java.el --- Java configuration with java-ts-mode and Eglot -*- lexical-binding: t; -*-

;; 中文说明：依赖本地 bin/ 中由 Mason 管理的 jdtls；缺失时仍可正常编辑 Java 文件。


(use-package cc-mode
  :straight nil
  ;; java-mode 不依赖 grammar；grammar 就绪时由 treesit-auto 自动升级。
  :mode ("\\.java\\'" . java-mode)
  :hook ((java-mode java-ts-mode) . my/lsp-maybe-ensure)
  :config
  (setq c-basic-offset 4
        java-ts-mode-indent-offset 4))

(provide 'lang-java)
;;; lang-java.el ends here

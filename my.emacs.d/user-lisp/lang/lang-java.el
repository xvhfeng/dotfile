;;; lang-java.el --- Java configuration with java-ts-mode and Eglot -*- lexical-binding: t; -*-

;; 中文说明：依赖本地 bin/ 中由 Mason 管理的 jdtls；缺失时仍可正常编辑 Java 文件。


(use-package java-ts-mode
  :ensure nil
  :mode "\\.java\\'"
  :hook (java-ts-mode . my/lsp-maybe-ensure)
  :config
  ;; 设置 Java 缩进策略
  (setq java-ts-mode-indent-offset 4))

(provide 'lang-java)
;;; lang-java.el ends here

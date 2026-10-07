;;; lang-java.el --- Java configuration with java-ts-mode and Eglot -*- lexical-binding: t; -*-

;;依赖外部 LSP 服务器：jdtls（Eclipse JDT Language Server）。


(use-package java-ts-mode
  :ensure nil
  :mode "\\.java\\'"
  :hook (java-ts-mode . eglot-ensure)
  :config
  ;; 设置 Java 缩进策略
  (setq java-ts-mode-indent-offset 4))

(provide 'lang-java)
;;; lang-java.el ends here
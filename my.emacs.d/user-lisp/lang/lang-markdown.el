;;; lang-markdown.el --- Compatibility shim -*- lexical-binding: t; -*-

;; Markdown 的完整配置已经迁移到独立的 init-markdown.el。保留这个 feature，
;; 以免旧的个人命令或缓存仍然 require `lang-markdown' 时加载失败。
(require 'init-markdown)

(provide 'lang-markdown)
;;; lang-markdown.el ends here

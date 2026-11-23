;;; init-hippie.el --- 手动动态扩展 -*- lexical-binding: t; -*-

;; Hippie Expand 随 Emacs 提供；只在手动调用时寻找候选，不加入 Corfu/Cape 的
;; 自动补全链，也不改变 Eglot 的代码语义候选。
(use-package hippie-exp
  :straight nil
  :commands hippie-expand
  :init
  ;; 常用的当前/其他 Buffer 词汇优先；文件、Lisp 符号和长文本随后尝试。
  ;; Kill Ring 中可能有无关旧文本，放到最后才参与轮换。
  (setq hippie-expand-try-functions-list
        '(try-expand-dabbrev
          try-expand-dabbrev-all-buffers
          try-expand-all-abbrevs
          try-complete-file-name-partially
          try-complete-file-name
          try-complete-lisp-symbol-partially
          try-complete-lisp-symbol
          try-expand-list
          try-expand-line
          try-expand-dabbrev-from-kill)))

;; M-/ 是 Emacs 原有的 dabbrev-expand；Hippie 包含这一候选源，单独保留
;; dabbrev-expand 在 C-c e v。C-c e d 已属于 Separedit，不占用它。
(with-eval-after-load 'general
  (general-define-key
   "M-/" '("动态扩展〔Hippie〕" . hippie-expand))
  (my-leader-def
    "e h" '("动态扩展〔Hippie〕" . hippie-expand)
    "e v" '("原生动态缩写补全〔Emacs〕" . dabbrev-expand)))

(provide 'init-hippie)
;;; init-hippie.el ends here

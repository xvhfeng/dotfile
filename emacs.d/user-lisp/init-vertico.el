;;; -*- lexical-binding: t -*-


;; 使用 Vertico（完全基于原生 completing-read，不改变原生数据结构）
(use-package vertico
             :ensure t
             :init
             (vertico-mode 1)
             :bind (:map vertico-map
                          ("TAB" . vertico-next)
                        ("<backtab>" . vertico-previous)
                         ;; 当输入 / 且当前高亮是目录时，直接进入
                         ("/" . vertico-insert)))

(provide 'init-vertico)

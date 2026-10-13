;;; -*- lexical-binding: t -*-


;; 使用 Vertico（完全基于原生 completing-read，不改变原生数据结构）
(use-package vertico
             :ensure t
             :init
             (vertico-mode 1)
             :general
             (:keymaps 'vertico-map
              "TAB" '("next candidate" . vertico-next)
              "<backtab>" '("previous candidate" . vertico-previous)
              "/" '("insert candidate" . vertico-insert)))

(provide 'init-vertico)

;;; -*- lexical-binding: t -*-


;; 使用 Vertico（完全基于原生 completing-read，不改变原生数据结构）
(use-package vertico
             :ensure t
             :init
             (vertico-mode 1)
             :general
             (:keymaps 'vertico-map
              "TAB" '(vertico-next :which-key "next candidate")
              "<backtab>" '(vertico-previous :which-key "previous candidate")
              "/" '(vertico-insert :which-key "insert candidate")))

(provide 'init-vertico)

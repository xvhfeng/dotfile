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

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 本模块当前未加入 `my/init-modules'，是旧的最小 Vertico 备选配置。
;; - 当前实际使用 init-minbuffer.el；不要同时启用本模块，以免 `TAB' 和 `/` 行为互相覆盖。
;; - 单独启用后，Minibuffer 中 `TAB/S-TAB' 选择下/上候选，`/' 插入候选。
;; - 本模块没有 Leader 快捷键；需要切换方案时修改 init.el 的模块列表。

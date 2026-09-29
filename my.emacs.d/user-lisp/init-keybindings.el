;; -*- lexical-binding: t -*-

;; 电感式”的 Buffer 列表模式 electric-buffer-list
;; 开启后，光标会直接定位到列表，而且选完 Buffer 回车后窗口会自动恢复
(global-set-key (kbd "C-x C-b") 'electric-buffer-list)



(message "my keybindings  loaded!")
(provide 'init-keybindings)
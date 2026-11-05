;;; init-magit-board.el --- Local Magit Board integration -*- lexical-binding: t; -*-
;; 显式加载源码路径，避免受受管字节编译的 `load-path' 时机影响。
(eval-and-compile
  (load (expand-file-name "plugins/magit-board/magit-board.el"
                          user-emacs-directory)
        nil nil t))
(setq magit-board-storage-file (my/runtime-file "magit-board/projects.eld"))
(with-eval-after-load 'general
  (my-leader-def "g B" '("Magit 项目面板" . magit-board-open)))
(provide 'init-magit-board)

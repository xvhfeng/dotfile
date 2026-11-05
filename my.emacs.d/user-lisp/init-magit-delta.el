;;; init-magit-delta.el --- Magit Delta integration -*- lexical-binding: t; -*-

(use-package magit-delta
  :straight (:host github :repo "dandavison/magit-delta")
  :after magit
  :hook (magit-mode . magit-delta-mode))

(provide 'init-magit-delta)

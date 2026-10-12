;;; -*- lexical-binding: t -*-

;;; 中文导读：Web 文件编辑。web-mode 处理 HTML 与模板，html/mhtml/css 的
;;; Tree-sitter 模式处理标准标记和样式，Emmet 用缩写生成标签。web-mode 中
;;; C-c C-h 重载、C-c C-i 缩进缓冲区、M-]/M-[ 跳下/上一个标签、C-M-]/C-M-[
;;; 跳属性、C-c C-f 折叠、C-c C-w/k/r/c 包裹/删除/重命名/克隆元素、C-c /
;;; 闭合元素、C-c t s/m 选择/匹配标签；M-E 展开 Emmet 缩写。
(use-package css-mode
  :straight nil
  :custom (css-fontify-colors nil))

(use-package css-ts-mode
  :straight nil
  :if (treesit-language-available-p 'css)
  :mode "\\.css\\'")

(use-package html-ts-mode
  :straight nil
  :if (treesit-language-available-p 'html))

(use-package mhtml-ts-mode
  :straight nil
  :if (and (treesit-language-available-p 'html)
           (treesit-language-available-p 'css)
           (treesit-language-available-p 'javascript))
  :mode "\\.\\(html?\\|vue\\)$"
  :custom (mhtml-ts-mode-css-fontify-colors nil))

(use-package web-mode
  :if (not (featurep 'mhtml-ts-mode))
  :mode "\\.[px]?html?\\'"
  :mode "\\.\\(?:tpl\\|blade\\)\\(?:\\.php\\)?\\'"
  :mode "\\.erb\\'"
  :mode "\\.[lh]?eex\\'"
  :mode "\\.jsp\\'"
  :mode "\\.as[cp]x\\'"
  :mode "\\.ejs\\'"
  :mode "\\.hbs\\'"
  :mode "\\.mustache\\'"
  :mode "\\.svelte\\'"
  :mode "\\.twig\\'"
  :mode "\\.jinja2?\\'"
  :mode "\\.eco\\'"
  :mode "wp-content/themes/.+/.+\\.php\\'"
  :mode "templates/.+\\.php\\'"
  :mode "\\.vue\\'"
  :general
  (:keymaps 'web-mode-map
   "C-c C-h" '(web-mode-reload :which-key "reload")
   "C-c C-i" '(web-mode-buffer-indent :which-key "indent buffer")
   "M-]" '(web-mode-tag-next :which-key "next tag")
   "M-[" '(web-mode-tag-previous :which-key "previous tag")
   "C-M-]" '(web-mode-attribute-next :which-key "next attribute")
   "C-M-[" '(web-mode-attribute-previous :which-key "previous attribute")
   "C-c C-f" '(web-mode-fold-or-unfold :which-key "toggle fold")
   "C-c C-w" '(web-mode-element-wrap :which-key "wrap element")
   "C-c C-k" '(web-mode-element-kill :which-key "kill element")
   "C-c C-r" '(web-mode-element-rename :which-key "rename element")
   "C-c C-c" '(web-mode-element-clone :which-key "clone element")
   "C-c /" '(web-mode-element-close :which-key "close element")
   "C-c t s" '(web-mode-tag-select :which-key "select tag")
   "C-c t m" '(web-mode-tag-match :which-key "match tag"))
  :custom
  (web-mode-auto-close-style 1)
  (web-mode-markup-indent-offset nn-indent-offset)
  (web-mode-code-indent-offset nn-indent-offset)
  (web-mode-css-indent-offset nn-indent-offset)
  (web-mode-enable-css-colorization nil)
  (web-mode-enable-auto-closing t)
  (web-mode-enable-current-element-highlight t)
  (web-mode-enable-html-entities-fontification t)
  :config
  (setf (alist-get "javascript" web-mode-comment-formats nil nil #'equal) "//")
  (add-to-list 'web-mode-engines-alist '("elixir" . "\\.eex\\'"))
  (add-to-list 'web-mode-engines-alist '("phoenix" . "\\.[lh]eex\\'")))

(use-package emmet-mode
  :general
  (:keymaps 'emmet-mode-keymap
   [tab] '(my-web/indent-or-yas-or-emmet-expand :which-key "expand/indent")
   "M-E" '(emmet-expand-line :which-key "expand Emmet abbreviation"))
  :hook (web-mode html-mode html-ts-mode mhtml-mode mhtml-ts-mode css-mode css-ts-mode)
  :custom
  (emmet-move-cursor-between-quotes t)
  (emmet-move-cursor-after-expanding t)
  :config
  (when (require 'yasnippet nil t)
    (add-hook 'emmet-mode-hook #'yas-minor-mode-on))

  (defun my-web/indent-or-yas-or-emmet-expand ()
    "Do-what-I-mean on TAB.

Invokes `indent-for-tab-command' if at or before text bol, `yas-expand' if on a
snippet, or `emmet-expand-yas'/`emmet-expand-line', depending on whether
`yas-minor-mode' is enabled or not."
    (interactive)
    (call-interactively
     (cond ((or (<= (current-column) (current-indentation))
                (not (eolp))
                (not (or (memq (char-after) (list ?\n ?\s ?\t))
                         (eobp))))
            #'indent-for-tab-command)
           ((featurep 'yasnippet)
            (require 'yasnippet)
            (if (yas--templates-for-key-at-point)
                #'yas-expand
              #'emmet-expand-yas))
           (#'emmet-expand-line)))))

(provide 'lang-web)

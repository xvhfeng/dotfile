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
   "C-c C-h" '("reload" . web-mode-reload)
   "C-c C-i" '("indent buffer" . web-mode-buffer-indent)
   "M-]" '("next tag" . web-mode-tag-next)
   "M-[" '("previous tag" . web-mode-tag-previous)
   "C-M-]" '("next attribute" . web-mode-attribute-next)
   "C-M-[" '("previous attribute" . web-mode-attribute-previous)
   "C-c C-f" '("toggle fold" . web-mode-fold-or-unfold)
   "C-c C-w" '("wrap element" . web-mode-element-wrap)
   "C-c C-k" '("kill element" . web-mode-element-kill)
   "C-c C-r" '("rename element" . web-mode-element-rename)
   "C-c C-c" '("clone element" . web-mode-element-clone)
   "C-c /" '("close element" . web-mode-element-close)
   "C-c t s" '("select tag" . web-mode-tag-select)
   "C-c t m" '("match tag" . web-mode-tag-match))
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
  (which-key-add-keymap-based-replacements
    web-mode-map
    "C-c C-a" "Attributes"
    "C-c C-b" "Blocks"
    "C-c C-d" "DOM"
    "C-c C-e" "Elements"
    "C-c C-t" "Tags"
    "C-c t" "Tags")
  (setf (alist-get "javascript" web-mode-comment-formats nil nil #'equal) "//")
  (add-to-list 'web-mode-engines-alist '("elixir" . "\\.eex\\'"))
  (add-to-list 'web-mode-engines-alist '("phoenix" . "\\.[lh]eex\\'")))

(use-package emmet-mode
  :general
  (:keymaps 'emmet-mode-keymap
   [tab] '("expand/indent" . my-web/indent-or-yas-or-emmet-expand)
   "M-E" '("expand Emmet abbreviation" . emmet-expand-line))
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

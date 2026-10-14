;;; init-template.el --- 新建代码文件模板 -*- lexical-binding: t; -*-

;; 中文说明：使用 Emacs 内置 auto-insert，不引入第三方依赖；仅在打开不存在且
;; 为空的新文件时插入模板，已有文件和非空文件不会被改写。
(require 'autoinsert)

(defconst my/template-directory
  (file-name-as-directory (expand-file-name "template/" user-emacs-directory))
  "存放新建文件模板的目录。")

;; 中文说明：首次启动时自动创建模板目录，使用户可直接在其中添加或修改模板。
(unless (file-directory-p my/template-directory)
  (make-directory my/template-directory t))

(defun my/template-expand-placeholders ()
  "展开当前模板中的文件名、基础名、日期和光标位置占位符。"
  (let* ((file-name (or (and buffer-file-name
                             (file-name-nondirectory buffer-file-name))
                        "untitled"))
         (base-name (file-name-base file-name))
         (date (format-time-string "%Y-%m-%d"))
         cursor-position)
    (save-excursion
      (goto-char (point-min))
      (dolist (replacement `(("__FILE_NAME__" . ,file-name)
                             ("__BASE_NAME__" . ,base-name)
                             ("__DATE__" . ,date)))
        (while (search-forward (car replacement) nil t)
          (replace-match (cdr replacement) t t)))
      (goto-char (point-min))
      (when (search-forward "__CURSOR__" nil t)
        (setq cursor-position (match-beginning 0))
        (replace-match "" t t)))
    ;; 中文说明：模板没有光标占位符时，默认将光标放在文件末尾。
    (goto-char (or cursor-position (point-max)))))

;; 中文说明：文件扩展名与模板文件一一对应。后续新增语言时，只需在 template/
;; 新增文件，并向此列表添加一条规则即可；模板本身可使用上面的四种占位符。
(dolist (rule '(("\\.c\\'" "C 源文件" "c.c")
                ("\\.\\(?:cc\\|cp\\|cpp\\|cxx\\|C\\)\\'" "C++ 源文件" "cpp.cpp")
                ("\\.go\\'" "Go 源文件" "go.go")
                ("\\.java\\'" "Java 源文件" "java.java")
                ("\\.ts\\'" "TypeScript 源文件" "typescript.ts")))
  (define-auto-insert (cons (nth 0 rule) (nth 1 rule))
    (vector (expand-file-name (nth 2 rule) my/template-directory)
            #'my/template-expand-placeholders)))

;; 中文说明：新建文件时直接插入匹配模板，不重复询问；手动调用 auto-insert
;; 仍遵循 Emacs 原生行为。
(setq auto-insert-query nil)
(auto-insert-mode 1)

(provide 'init-template)

;; ---------------------------------------------------------------------------
;; 使用说明
;; ---------------------------------------------------------------------------
;; - 新建 .c/.cpp/.go/.java/.ts 文件后，模板会自动插入。
;; - `__FILE_NAME__`、`__BASE_NAME__`、`__DATE__`、`__CURSOR__` 会自动展开。
;; - 修改 template/ 下对应文件后，下一次新建文件立即使用新内容。

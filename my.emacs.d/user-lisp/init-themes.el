;;; -*- lexical-binding: t -*-

;;;========================================================================
;;; 配置emacs使用的主题
;;;========================================================================

(use-package ef-themes
    :straight (:host github :repo "protesilaos/ef-themes")
  :demand t
  :config
  ;; 设置 toggle 命令在 ef-spring (亮色) 与 ef-autumn (暗色) 之间切换
  ;; (setq ef-themes-to-toggle '(ef-spring ef-autumn))

(setq ef-themes-italic-constructs t    ; 开启关键字/注释斜体
      ef-themes-bold-constructs t)     ; 开启重点语法粗体
  
  ;; 默认加载 ef-spring
  (load-theme 'ef-spring t))

(message "themes loaded!")
(provide 'init-themes)

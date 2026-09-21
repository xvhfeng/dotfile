;;; -*- lexical-binding: t -*-

;;; 中文导读：通用工具。Man/Proced/time 提供手册、进程和时间；webjump 快速搜索
;;; 网站；rg 调用 ripgrep，wgrep 允许直接编辑搜索结果；calfw/calfw-org 显示日历；
;;; simple-mpv 播放媒体；nn-license-template 插入许可证。C-c / 网页搜索，C-c s
;;; 搜当前目录，C-c C-s 打开 rg 菜单，C-c C-c 打开 Org 日历，C-c m 浏览音频；
;;; Dired 中 C-c p 播放文件，C-c l f/h 插入许可证全文/文件头。
;; Proced: Emacs 内置的系统进程管理器 (类似 htop/top)
(use-package proced
  :ensure nil
  :custom
  (proced-enable-color-flag t)                   ; 开启彩色高亮显示
  (proced-tree-flag t)                         ; 默认开启进程树状图（父子进程嵌套关系）
  (proced-auto-update-flag 'visible)            ; 仅当 Proced 窗口在屏内可见时才自动更新（省 CPU）
  (proced-auto-update-interval 1)               ; 自动更新间隔为 1 秒
  (proced-descend t)                            ; 进程排序默认采用降序
  (proced-format 'medium)                       ; 使用中等粒度的列展示格式（包含 PID、CPU%、MEM% 等）
  (proced-filter 'user))                        ; 默认仅过滤显示当前用户运行的进程

;; Time & World Clock: 系统时间与世界时钟
(use-package time
  :ensure nil
  :custom
  (world-clock-time-format "%A %d %B %H:%M:%S %Z") ; 世界时钟时间显示格式 (如 Friday 18 September 17:48:15 JST)
  (world-clock-sort-order "%FT%T")               ; 按 ISO 8601 标准时间格式对列表进行排序
  (display-time-day-and-date t)                 ; 状态栏 (Mode-line) 显示日期和星期
  (display-time-default-load-average nil)        ; 状态栏隐藏系统 CPU 负载平均值
  (display-time-mail-string "")                  ; 不显示邮件状态提示
  ;; 运行 `M-x worldclock` 时展示的时区和别名列表
  (zoneinfo-style-world-list
   '(("America/Los_Angeles" "Los Angeles")
     ("America/Vancouver" "Vancouver")
     ("Canada/Pacific" "Canada/Pacific")
     ("America/Chicago" "Chicago")
     ("America/Toronto" "Toronto")
     ("America/New_York" "New York")
     ("Canada/Atlantic" "Canada/Atlantic")
     ("Brazil/East" "Brasília")
     ("America/Sao_Paulo" "São Paulo")
     ("UTC" "UTC")
     ("Europe/Lisbon" "Lisbon")
     ("Europe/Brussels" "Brussels")
     ("Europe/Athens" "Athens")
     ("Asia/Riyadh" "Riyadh")
     ("Asia/Amman" "Jordan")
     ("Asia/Tehran" "Tehran")
     ("Asia/Tbilisi" "Tbilisi")
     ("Asia/Yekaterinburg" "Yekaterinburg")
     ("Asia/Kolkata" "Kolkata")
     ("Asia/Singapore" "Singapore")
     ("Asia/Shanghai" "Shanghai")
     ("Asia/Seoul" "Seoul")
     ("Asia/Tokyo" "Tokyo")
     ("Asia/Vladivostok" "Vladivostok")
     ("Australia/Brisbane" "Brisbane")
     ("Australia/Sydney" "Sydney")
     ("Pacific/Auckland" "Auckland"))))

;; Man: 查看 Unix/Linux 系统的 man 手册
(use-package man
  :ensure nil
  :commands man
  :custom (Man-notify-method 'pushy))            ; 'pushy 模式：打开手册时强制占用并替换当前窗口焦点

;; Webjump: 终端/编辑器内部的快捷网络搜索跳转
(use-package webjump
  :ensure nil
  :bind ("C-c /" . my-webjump-eww)              ; C-c / 呼出搜索菜单
  :custom
  ;; 配置跳转网站列表及各自的 Query URL 结构
  (webjump-sites
   '(("DuckDuckGo"     . [simple-query "https://www.duckduckgo.com"
                                       "https://www.duckduckgo.com/?q=" ""])
     ("DuckDuckAI"     . [simple-query "https://duck.ai" "https://duck.ai/?q=" ""])
     ("DuckDuckGoImg"  . [simple-query "https://www.duckduckgo.com"
                                       "https://www.duckduckgo.com/?iar=images&q=" ""])
     ("Bing"           . [simple-query "www.bing.com" "www.bing.com/search?q=" ""])
     ("Google"         . [simple-query "https://www.google.com"
                                       "https://www.google.com/search?q=" ""])
     ("YouTube"        . [simple-query "https://www.youtube.com/feed/subscriptions"
                                       "https://www.youtube.com/results?search_query=" ""])
     ("Wikipedia"      . [simple-query "wikipedia.org" "wikipedia.org/wiki/" ""])))
  :config
  ;; 交互式函数：未带通用前缀参数 C-u 时使用外部默认浏览器，带前缀参数时临时强制使用 EWW 内置浏览器
  (defun my-webjump-eww (&optional arg)
    (require 'eww)
    (let ((webjump-use-internal-browser arg))
      (call-interactively #'webjump))))

;; Wgrep: 可写搜索 Buffer（修改搜索结果并反写回源文件）
(use-package wgrep
  :custom
  (wgrep-auto-save-buffer t)                     ; 在 wgrep-buffer 退出保存时，自动保存所有被修改的磁盘文件
  (wgrep-change-readonly-file t))                ; 允许 wgrep 强制修改只读文件（并在修改后应用）

;; Rg: Ripgrep 交互包
(use-package rg
  :commands rg
  :hook (rg-mode . (lambda () (setq-local compilation-insert-header-function #'ignore))) ; 隐藏顶部冗余的命令/提示信息 Header
  :bind
  (("C-c s" . my-rg-current-dir-all)             ; C-c s 搜索当前目录所有文件
   ("C-c C-s" . rg-menu)                         ; C-c C-s 弹出 rg 参数交互菜单
   :map rg-global-map
   ("c" . rg-dwim-current-dir)                   ; 智能按当前光标下 Symbol 搜索当前目录
   ("f" . rg-dwim-current-file)                  ; 智能按当前光标下 Symbol 搜索当前文件
   ("m" . rg-menu))
  :custom (rg-keymap-prefix nil)                 ; 取消默认设置的前缀快捷键，改用上面手动绑定的规则
  :config
  ;; 包装函数：按字面量匹配模式搜索当前目录下的所有文件 (`*`)
  (defun my-rg-current-dir-all (query)
    "Search QUERY in all files under current directory."
    (interactive "sSearch: ")
    (rg-literal query "*" default-directory)))

;; Calfw: 基于 Buffer 的图形化日历核心组件
(use-package calfw
  :custom
  ;; 使用复杂的 Unicode 表格线字符替换默认的 ASCII 符号 (+ | -)，提升 UI 现代感
  (calfw-fchar-junction ?╋)
  (calfw-fchar-vertical-line ?┃)
  (calfw-fchar-horizontal-line ?━)
  (calfw-fchar-left-junction ?┣)
  (calfw-fchar-right-junction ?┫)
  (calfw-fchar-top-junction ?┯)
  (calfw-fchar-top-left-corner ?┏)
  (calfw-fchar-top-right-corner ?┓)
  (calfw-show-holidays nil))                     ; 默认关闭节假日显示

;; Calfw-Org: 将 Org-mode 日程/任务同步渲染至 Calfw 日历面板
(use-package calfw-org
  :commands calfw-org-open-calendar
  :bind ("C-c C-c" . my-calfw-open)
  :config
  ;; 打开日历的同时调小字体一行，使得当月日期和日程视图能舒适地塞进单个 Screen
  (defun my-calfw-open ()
    (interactive)
    (calfw-org-open-calendar)
    (text-scale-set -1)
    (calfw-refresh-calendar-buffer)))

;; Simple-MPV: MPV 播放器集成
(use-package simple-mpv
  :ensure nil                                    ; 私有或本地扩展包
  :custom (simple-mpv-debug nil)                ; 关闭调试日志输出
  :bind
  (("C-c m" . simple-mpv-audio-browse)          ; C-c m 交互式浏览并播放音频
   :map dired-mode-map
   ("C-c p" . simple-mpv-play-file)))            ; 在 Dired 文件管理器中按 C-c p 直接播放光标处的文件

;; NN-License-Template: 本地自定义的 开源许可证/代码头生成扩展
(use-package nn-license-template
  :ensure nil                                    ; 本地扩展
  :defer nil                                     ; 不延迟加载
  :bind
  ("C-c l f" . nn-license-template-file)        ; C-c l f 插入独立许可证文件 (如 LICENSE)
  ("C-c l h" . nn-license-template-header))     ; C-c l h 插入源码文件顶部的 License Header 注释

(provide 'init-utils)

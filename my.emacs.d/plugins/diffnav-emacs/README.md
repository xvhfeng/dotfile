# diffnav-emacs

在 Emacs 中通过高性能 `vterm` 启动 [diffnav](https://github.com/dlvhdr/diffnav)。

它不替换 Magit 或 Emacs 的原生 Diff Mode：仅在需要浏览 Git 改动时，打开完整的 diffnav TUI。

可配置项：

- `diffnav-emacs-executable`：可执行文件名或绝对路径。
- `diffnav-emacs-extra-arguments`：例如 `("--unified")`。
- `diffnav-emacs-terminal-function`：默认 `diffnav-emacs-vterm`，可替换为其他终端启动函数，签名为 `(COMMAND DIRECTORY)`。

默认后端会用 `exec` 替换 vterm 的 shell；因此在 diffnav 中按 `q` 时，关联 vterm Buffer 会自动关闭。

可交互命令：`diffnav-emacs-working-tree`、`diffnav-emacs-staged`、`diffnav-emacs-current-file-menu`、`diffnav-emacs-watch-working-tree`，以及按文件状态划分的五个当前文件命令。

# Magit Board

只读 Git 项目面板。项目记录保存为 `(:name NAME :path PATH)`；初始化模块将数据文件设为 `runtimes/magit-board/projects.eld`。

| Key | Action |
| --- | --- |
| `j` / `k` | 上下移动 |
| `a` | 添加 Git 项目 |
| `m` | 修改当前项目路径 |
| `d` | 确认删除项目 |
| `RET` | 打开当前项目 Magit Status |
| `l` | 打开当前项目 Magit Log |
| `g` | 刷新 |
| `q` | 关闭 |

入口：`C-c g b`。

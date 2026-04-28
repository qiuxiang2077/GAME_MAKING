# game/ — 游戏项目

用 Godot 4.6 打开 `project.godot` 即可运行。

## 目录说明

| 文件夹 | 说明 |
|-------|------|
| scenes/ | Godot场景文件(.tscn)，含关卡、Boss战、主菜单等 |
| scripts/ | GDScript游戏逻辑脚本 |
| ui/ | HUD界面（脚本+场景） |
| assets/ | 美术(art/)和音频(audio/)资源 |
| levels/ | 关卡数据（当前为空，关卡数据暂存在scenes/） |

## 入口

`main.tscn` — 启动场景，自动加载游戏管理器

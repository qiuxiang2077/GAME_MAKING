# 《影梦》(Silhouette Dream)

> 横版剧情向解谜冒险 | Godot 4.6 | 千禧年梦核风

探索解谜导向，无战斗，聚焦叙事与氛围。

## 快速启动

```bash
# 用 Godot 4.6 打开 game/project.godot
godot game/project.godot
```

**操作**：WASD移动 | Shift奔跑 | E/空格互动 | Ctrl躲藏

## 项目结构

```
GAME_MAKING/
├── game/               # Godot游戏项目（开这个目录跑游戏）
│   ├── scenes/         # Godot场景
│   ├── scripts/        # GDScript
│   ├── ui/             # UI系统
│   ├── assets/         # 资源文件
│   ├── levels/         # 关卡
│   └── project.godot   # 项目文件
├── development/        # 开发辅助
│   ├── docs/           # 文档（设定.md、agents.md、tech/）
│   ├── wiki/           # 游戏百科HTML
│   ├── openspec/       # 变更管理
│   ├── godot-mcp/      # Godot MCP工具
│   └── README.md       # 本文件
├── .trae/              # AI规则配置（隐藏）
└── LICENSE
```

## 当前状态

| 模块 | 状态 |
|-----|------|
| 游戏设定 | 已定稿 |
| 玩家系统 (player.gd) | 已完成 |
| 敌人系统 (enemy.gd) | 已完成 |
| 睡眠阶段系统 (sleep_manager.gd) | 已完成 |
| 游戏管理器 (game_manager.gd) | 已完成 |
| UI系统 (hud.gd/tscn) | 已完成 |
| 谜题系统 (puzzles/) | 已完成 |
| 场景 | Demo关卡、迷宫关卡、Boss关卡 |
| 核心玩法机制 | 已确定（探索解谜导向） |

## 开发路线

1. 核心玩法原型（当前）→ 2. 美术资源制作 → 3. 叙事内容填充 → 4. 完整关卡 → 5. 测试打磨

## 重要原则

- **文档优先**：变更先更新文档，再执行实现
- **单文件设定**：所有游戏设定统一在 `development/docs/设定.md`
- **实现映射**：代码变更需同步更新 `development/docs/tech/实现映射.md`

# scripts/ — 游戏脚本

GDScript 脚本，按系统分类：

## 玩家系统

| 脚本 | 功能 |
|-----|------|
| player.gd | 玩家控制（移动/互动/躲藏/恐惧影响） |
| character.gd / character_node.gd | 角色基类和节点 |

## 敌人系统

| 脚本 | 功能 |
|-----|------|
| enemy.gd | 敌人AI（巡逻/追踪/潜伏三种模式） |
| bear_boss.gd / doctor_boss.gd | Boss行为逻辑 |
| npc_system.gd | NPC对话系统 |

## 梦境系统

| 脚本 | 功能 |
|-----|------|
| sleep_manager.gd | 睡眠四阶段（清醒→浅睡→深睡→REM） |
| time_system.gd | 游戏内时间管理 |
| light_sleep_effects.gd | 浅睡期状态波动/幻觉 |
| vision_system.gd | 视野/照明系统 |
| emotion_system.gd | REM期情感共鸣（安抚敌人） |

## 游戏管理

| 脚本 | 功能 |
|-----|------|
| game_manager.gd | 全局游戏状态管理 |
| narrative_system.gd | 叙事/对话管理 |
| item_system.gd | 道具系统（安抚/照明/保护/记忆） |
| farming_system.gd | 种植系统 |

## 杂物

| 脚本 | 功能 |
|-----|------|
| collectible.gd | 可收集物（记忆碎片） |
| safe_zone.gd | 安全区域 |
| main_menu.gd | 主菜单逻辑 |

## 谜题

`puzzles/` — 推箱子、压力板、开关门等解谜组件

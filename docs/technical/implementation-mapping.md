# 技术实现与设计文档对应表

> **规则**：所有代码实现必须对应设计文档，本文档维护代码与设计文档的映射关系

---

## 一、设计文档索引

| 设计文档 | 路径 | 说明 |
|---------|------|------|
| 游戏性设定 | `docs/design/gameplay/mechanics.md` | 核心玩法机制定义 |
| 项目管理 | `docs/project/overview.md` | 项目整体规划 |

---

## 二、核心系统实现映射

### 2.1 睡眠阶段系统

**设计文档来源**：`mechanics.md` 第1.2-1.3节

| 设计定义 | 实现文件 | 实现状态 | 代码位置 |
|---------|---------|---------|---------|
| 清醒期 (AWAKE) | `scripts/sleep_manager.gd` | ✅ 已实现 | `SleepStage.AWAKE` |
| 浅睡期 (LIGHT_SLEEP) | `scripts/sleep_manager.gd` | ✅ 已实现 | `SleepStage.LIGHT_SLEEP` |
| 深睡期 (DEEP_SLEEP) | `scripts/sleep_manager.gd` | ✅ 已实现 | `SleepStage.DEEP_SLEEP` |
| REM期 | `scripts/sleep_manager.gd` | ✅ 已实现 | `SleepStage.REM` |
| 阶段持续时间 | `scripts/sleep_manager.gd` | ✅ 已实现 | `stage_durations` 字典 |
| 恐惧值系统 | `scripts/sleep_manager.gd` | ✅ 已实现 | `fear_level` 变量 |
| 情绪能量系统 | `scripts/sleep_manager.gd` | ✅ 已实现 | `emotional_energy` 变量 |
| 阶段切换逻辑 | `scripts/sleep_manager.gd` | ✅ 已实现 | `_next_stage()` 方法 |

**实现说明**：
- 计时器每秒触发一次，更新剩余时间
- 深睡期恐惧值自动增长（0.5/秒）
- REM期情绪能量自动恢复（0.3/秒）

---

### 2.2 玩家操作系统

**设计文档来源**：`mechanics.md` 第0.2节玩家操作表

| 设计定义 | 实现文件 | 实现状态 | 代码位置 | InputMap名称 |
|---------|---------|---------|---------|-------------|
| 方向键/WASD移动 | `scripts/player.gd` | ✅ 已实现 | `_physics_process()` | `move_up/down/left/right` |
| Shift快速行走 | `scripts/player.gd` | ✅ 已实现 | 第26行 | `run` |
| Ctrl躲藏 | `scripts/player.gd` | ✅ 已实现 | `_physics_process()` 第30-37行 | `hide` |
| E/空格互动 | `scripts/player.gd` | ✅ 已实现 | `interact()` 方法 | `interact` |

**实现说明**：
- 移动速度：200（行走）/ 350（奔跑）
- 躲藏时视觉变半透明（Color(0.2, 0.2, 0.2, 0.5)）
- 躲藏时无法移动

---

### 2.3 敌人类型系统

**设计文档来源**：`mechanics.md` 第2.4节敌人行为模式表

| 设计定义 | 实现文件 | 实现状态 | 代码位置 |
|---------|---------|---------|---------|
| 巡逻型 (PATROL) | `scripts/enemy.gd` | ✅ 已实现 | `EnemyType.PATROL` + `patrol_behavior()` |
| 追踪型 (TRACKING) | `scripts/enemy.gd` | ✅ 已实现 | `EnemyType.TRACKING` + `chase_behavior()` |
| 潜伏型 (HIDDEN) | `scripts/enemy.gd` | ✅ 已实现 | `EnemyType.HIDDEN` |
| 感应型 (SENSITIVE) | `scripts/enemy.gd` | ✅ 已实现 | `EnemyType.SENSITIVE` |

**实现说明**：
- 巡逻范围：150像素
- 追踪范围：300像素
- 追踪持续时间：5秒
- 巡逻速度：80，追踪速度：120

---

### 2.4 收集系统

**设计文档来源**：`mechanics.md` 第0.2节核心玩法循环

| 设计定义 | 实现文件 | 实现状态 | 代码位置 |
|---------|---------|---------|---------|
| 记忆碎片收集 | `scripts/collectible.gd` | ✅ 已实现 | `collect()` 方法 |
| 收集计数 | `scripts/game_manager.gd` | ✅ 已实现 | `memory_fragments` |
| 收集反馈 | `scripts/collectible.gd` | ✅ 已实现 | 闪烁动画+消失效果 |
| 胜利条件 | `scripts/game_manager.gd` | ✅ 已实现 | `all_memories_collected` 信号 |

**实现说明**：
- 总碎片数：7个
- 收集后播放闪烁动画（3次缩放+颜色变化）
- 收集后0.3秒内缩放到0.1并淡出

---

### 2.5 UI系统

**设计文档来源**：`mechanics.md` 第4.1节睡眠阶段UI

| 设计定义 | 实现文件 | 实现状态 | 代码位置 |
|---------|---------|---------|---------|
| 阶段指示器 | `ui/hud.gd` | ✅ 已实现 | `StageLabel` |
| 恐惧值显示 | `ui/hud.gd` | ✅ 已实现 | `FearLabel` + 颜色变化 |
| 剩余时间显示 | `ui/hud.gd` | ✅ 已实现 | `TimeLabel` |
| 记忆碎片计数 | `ui/hud.gd` | ✅ 已实现 | `MemoryLabel` |
| 游戏结束面板 | `ui/hud.gd` | ✅ 已实现 | `GameOverPanel` |
| 胜利面板 | `ui/hud.gd` | ✅ 已实现 | `VictoryPanel` + 星星动画 |

**实现说明**：
- HUD使用CanvasLayer，层级100
- 恐惧值<30绿色，<60黄色，>=60红色
- 记忆收集时标签缩放动画（1.5x → 1.0x）

---

## 三、场景结构映射

### 3.1 迷宫关卡 (maze_level.tscn)

| 设计概念 | 场景节点路径 | 实现状态 |
|---------|-------------|---------|
| 睡眠管理器 | `SleepManager` | ✅ 已实现 |
| 玩家角色 | `Player` | ✅ 已实现 |
| 迷宫墙壁 | `Environment/MazeWalls` | ✅ 已实现 |
| 敌人组 | `Enemies/Enemy1-4` | ✅ 已实现 (4个敌人) |
| 可收集物组 | `Collectibles/Memory1-7` | ✅ 已实现 (7个碎片) |
| HUD界面 | `HUD` | ✅ 已实现 |

---

## 四、碰撞层级定义

| 层级 | 用途 | 对应节点 |
|-----|------|---------|
| Layer 1 | 玩家 | Player |
| Layer 2 | 墙壁 | 所有MazeWalls |
| Layer 4 | 敌人 | Enemy1-4 |
| Layer 8 | 可收集物 | Memory1-7 |

---

## 五、待实现功能清单

根据设计文档，以下功能**尚未实现**，需要在后续迭代中补充：

| 设计文档章节 | 功能描述 | 优先级 |
|-------------|---------|-------|
| 1.3.1 清醒期 | 路线选择系统 | 中 |
| 1.3.1 清醒期 | 守门人对话 | 低 |
| 1.3.2 浅睡期 | 状态波动 (-20%~+20%) | 中 |
| 1.3.2 浅睡期 | 场景重组/锚点系统 | 高 |
| 1.3.2 浅睡期 | 记忆闪回 | 中 |
| 1.3.3 深睡期 | 真实伤害机制 | 中 |
| 1.3.3 深睡期 | 安全点系统 | 高 |
| 1.3.4 REM期 | 情感共鸣系统 | 高 |
| 1.3.4 REM期 | 环境重塑能力 | 中 |
| 2.3 解谜系统 | 环境谜题 | 高 |
| 2.5 医学元素 | 疾病异常状态 | 低 |

---

## 六、代码变更日志

| 日期 | 变更文件 | 变更内容 | 对应设计 |
|------|---------|---------|---------|
| 2026-04-20 | `scripts/player.gd` | 修复空引用检查 | 玩家操作系统 |
| 2026-04-20 | `scripts/enemy.gd` | 添加@onready预加载 | 敌人类型系统 |
| 2026-04-20 | `scripts/collectible.gd` | 修复GameManager获取 | 收集系统 |
| 2026-04-20 | `ui/hud.gd` | 添加节点空值检查 | UI系统 |

---

**文档版本**：1.0  
**创建日期**：2026-04-20  
**维护规则**：每次代码变更需同步更新本文档


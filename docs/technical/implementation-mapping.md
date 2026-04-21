# 技术实现与设计文档对应表

> **规则**：所有代码实现必须对应设计文档，本文档维护代码与文档的映射关系

---

## 一、设计文档索引

| 设计文档 | 路径 | 说明 |
|---------|------|------|
| 游戏性设定 | `docs/design/gameplay/mechanics.md` | 核心玩法机制定义 |
| 项目管理 | `docs/project/overview.md` | 项目整体规划 |
| 谜题系统设计 | `docs/technical/puzzle-system-design.md` | 环境解谜系统技术设计 |

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
| Shift快速行走 | `scripts/player.gd` | ✅ 已实现 | 第35行 | `run` |
| Ctrl躲藏 | `scripts/player.gd` | ✅ 已实现 | `_physics_process()` 第39-48行 | `hide` |
| E/空格互动 | `scripts/player.gd` | ✅ 已实现 | `interact()` 方法 | `interact` |
| 推箱子 | `scripts/player.gd` | ✅ 已实现 | `_start_push_box()` 方法 | - |

**实现说明**：
- 移动速度：200（行走）/ 350（奔跑）
- 躲藏时视觉变半透明（Color(0.2, 0.2, 0.2, 0.5)）
- 躲藏时无法移动
- 推动箱子时按互动键或停止移动可停止推动

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
| 剩余时间显示 | `
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

**设计文档来源**：`mechanics.md` 第1.2-1.5节

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
| 周期循环 (3-5个周期) | `scripts/sleep_manager.gd` | ✅ 已实现 | `current_cycle` + `max_cycles` |
| 恐惧值影响移动速度 | `scripts/sleep_manager.gd` | ✅ 已实现 | `get_fear_speed_multiplier()` |
| 重度恐慌无法控制 | `scripts/sleep_manager.gd` | ✅ 已实现 | `is_panic_state()` |
| 周期完成信号 | `scripts/sleep_manager.gd` | ✅ 已实现 | `cycle_completed` + `all_cycles_completed` |

**实现说明**：
- REM期结束 = 一个完整周期结束，回到清醒期开始新周期
- 最多5个周期，之后触发 `all_cycles_completed`
- 恐惧值<30: 速度1.0, <60: 0.9, <80: 0.85, >=80: 0.5+随机移动

---

### 2.2 玩家操作系统

**设计文档来源**：`mechanics.md` 第0.2节玩家操作表

| 设计定义 | 实现文件 | 实现状态 | 代码位置 |
|---------|---------|---------|---------|
| 方向键/WASD移动 | `scripts/player.gd` | ✅ 已实现 | `_physics_process()` |
| Shift快速行走 | `scripts/player.gd` | ✅ 已实现 | `is_running` |
| Ctrl躲藏 | `scripts/player.gd` | ✅ 已实现 | `is_hiding` |
| E/空格互动 | `scripts/player.gd` | ✅ 已实现 | `interact()` |
| 推箱子 | `scripts/player.gd` | ✅ 已实现 | `_start_push_box()` |
| 跑步吸引敌人 | `scripts/player.gd` | ✅ 已实现 | `_notify_enemies_running()` |
| 被敌人抓住 | `scripts/player.gd` | ✅ 已实现 | `caught_by_enemy()` |
| 恐惧影响移动 | `scripts/player.gd` | ✅ 已实现 | `speed_multiplier` + `panic` |

**实现说明**：
- 移动速度：200（行走）/ 350（奔跑），受恐惧值影响
- 跑步时通知400像素内敌人（`hear_noise`）
- 躲藏时不被敌人发现
- 重度恐慌时随机移动

---

### 2.3 敌人类型系统

**设计文档来源**：`mechanics.md` 第2.4节敌人行为模式表

| 设计定义 | 实现文件 | 实现状态 | 代码位置 |
|---------|---------|---------|---------|
| 巡逻型 (PATROL) | `scripts/enemy.gd` | ✅ 已实现 | `EnemyType.PATROL` + `patrol_behavior()` |
| 追踪型 (TRACKING) | `scripts/enemy.gd` | ✅ 已实现 | `EnemyType.TRACKING` + `chase_behavior()` |
| 潜伏型 (HIDDEN) | `scripts/enemy.gd` | ✅ 已实现 | `EnemyType.HIDDEN` |
| 感应型 (SENSITIVE) | `scripts/enemy.gd` | ✅ 已实现 | `EnemyType.SENSITIVE` |
| 声音感知 | `scripts/enemy.gd` | ✅ 已实现 | `hear_noise()` |
| 抓住玩家 | `scripts/enemy.gd` | ✅ 已实现 | `_check_catch_player()` |
| 躲藏时不被发现 | `scripts/enemy.gd` | ✅ 已实现 | `_on_detection_area_entered()` |

**实现说明**：
- 巡逻范围：150像素，追踪范围：300像素
- 抓住距离：20像素，触发游戏结束
- 感应型敌人听到声音立即追击
- 巡逻型敌人对声音有轻微反应（200像素内）

---

### 2.4 收集系统

**设计文档来源**：`mechanics.md` 第0.2节核心玩法循环

| 设计定义 | 实现文件 | 实现状态 | 代码位置 |
|---------|---------|---------|---------|
| 记忆碎片收集 | `scripts/collectible.gd` | ✅ 已实现 | `collect()` 方法 |
| 收集计数 | `scripts/game_manager.gd` | ✅ 已实现 | `memory_fragments` |
| 收集反馈 | `scripts/collectible.gd` | ✅ 已实现 | 闪烁动画+消失效果 |
| 胜利条件 | `scripts/game_manager.gd` | ✅ 已实现 | `all_memories_collected` 信号 |

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

---

### 2.6 环境解谜系统

**设计文档来源**：`mechanics.md` 第2.3节 + `puzzle-system-design.md`

| 设计定义 | 实现文件 | 实现状态 | 代码位置 |
|---------|---------|---------|---------|
| 压力踏板 | `scripts/puzzles/pressure_plate.gd` | ✅ 已实现 | `PressurePlate` class |
| 开关门 | `scripts/puzzles/switch_door.gd` | ✅ 已实现 | `SwitchDoor` class |
| 推拉箱子 | `scripts/puzzles/pushable_box.gd` | ✅ 已实现 | `PushableBox` class |
| 拨动开关 | `scripts/puzzles/toggle_switch.gd` | ✅ 已实现 | `ToggleSwitch` class |

---

## 三、场景结构映射

### 3.1 主场景 (demo_level.tscn)

| 设计概念 | 场景节点路径 | 实现状态 |
|---------|-------------|---------|
| 睡眠管理器 | `SleepManager` | ✅ 已实现 |
| 玩家角色 | `Player` | ✅ 已实现 |
| 敌人组 | `Enemies/Enemy1-3` | ✅ 已实现 (3个敌人，含DetectionArea) |
| 可收集物组 | `Collectibles/Memory1-5` | ✅ 已实现 (5个碎片，含Visual+Glow) |
| HUD界面 | `HUD` | ✅ 已实现 |

---

## 四、碰撞层级定义

| 层级 | 用途 | 对应节点 |
|-----|------|---------|
| Layer 1 | 玩家 | Player |
| Layer 2 | 墙壁/障碍物 | 所有StaticBody2D |
| Layer 4 | 敌人 | Enemy1-3 |
| Layer 8 | 可收集物 | Memory1-5 |

---

## 五、待实现功能清单

| 设计文档章节 | 功能描述 | 优先级 |
|-------------|---------|-------|
| 1.3.1 清醒期 | 路线选择系统 | 中 |
| 1.3.1 清醒期 | 守门人对话 | 低 |
| 1.3.2 浅睡期 | 状态波动 (-20%~+20%) | 中 |
| 1.3.2 浅睡期 | 场景重组/锚点系统 | 高 |
| 1.3.2 浅睡期 | 记忆闪回 | 中 |
| 1.3.3 深睡期 | 安全点系统 | 高 |
| 1.3.4 REM期 | 情感共鸣系统 | 高 |
| 1.3.4 REM期 | 环境重塑能力 | 中 |
| 2.3 解谜系统 | 场景中放置谜题实例 | 高 |
| 2.5 医学元素 | 疾病异常状态 | 低 |

---

## 六、代码变更日志

| 日期 | 变更文件 | 变更内容 | 对应设计 | 原因 |
|------|---------|---------|---------|------|
| 2026-04-20 | `project.godot` | 描述改为"俯视角"，主场景改为demo_level | 项目定义 | 横版→俯视角，simple_test→demo_level |
| 2026-04-20 | `scripts/sleep_manager.gd` | 周期循环逻辑，恐惧影响速度，恐慌状态 | 1.2-1.3节 | %4无限循环→周期结束机制 |
| 2026-04-20 | `scripts/player.gd` | 恐惧影响移动，跑步吸引敌人，被抓触发 | 0.2节+1.3.3节 | 设计文档要求但未实现 |
| 2026-04-20 | `scripts/enemy.gd` | 抓住玩家，声音感知，躲藏不被发现 | 2.4节 | 设计文档要求但未实现 |
| 2026-04-20 | `scenes/demo_level.tscn` | 节点名与脚本匹配，添加DetectionArea | 全部 | 场景节点名不匹配导致崩溃 |
| 2026-04-20 | `scripts/puzzles/*.gd` | 新增4个谜题脚本 | 2.3节 | 新功能 |
| 2026-04-20 | `ui/hud.gd` | 添加节点空值检查 | 4.1节 | 防止闪退 |

---

**文档版本**: 1.1  
**更新日期**: 2026-04-20  
**维护规则**: 每次代码变更需同步更新本文档

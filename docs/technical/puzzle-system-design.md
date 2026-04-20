# 环境解谜系统技术设计文档

> **对应设计文档**: `docs/design/gameplay/mechanics.md` 第2.3节  
> **文档类型**: 技术实现设计  
> **创建日期**: 2026-04-20

---

## 一、设计来源

**设计定义**（来自mechanics.md）：
> 环境解谜：利用场景物件解决 | 简单-中等难度 | 参考《锈湖》系列

**核心设计原则**：
- 谜题答案与角色背景故事相关
- 解谜过程揭示隐藏信息
- 完成谜题解锁新剧情片段
- 部分谜题需要特定情绪状态才能解决

---

## 二、系统架构

### 2.1 谜题基类设计

```gdscript
class_name PuzzleBase
extends Node2D

# 信号
signal puzzle_solved(puzzle_id)
signal puzzle_reset(puzzle_id)

# 基础属性
@export var puzzle_id: String = ""
@export var puzzle_name: String = ""
@export var required_stage: int = -1  # -1表示任意阶段
@export var is_solved: bool = false

# 虚方法 - 子类必须实现
func check_solved() -> bool:
    pass
    
func reset_puzzle():
    pass
```

### 2.2 谜题类型定义

| 谜题类型 | 类名 | 机制描述 | 难度 |
|---------|------|---------|------|
| 压力踏板 | PressurePlate | 需要持续按压激活 | 简单 |
| 开关门 | SwitchDoor | 开关控制门的开闭 | 简单 |
| 推拉箱子 | PushableBox | 可推动的物体 | 中等 |
| 多踏板联动 | MultiPlatePuzzle | 多个踏板需同时激活 | 中等 |

---

## 三、详细设计

### 3.1 压力踏板 (PressurePlate)

**功能描述**：
- 玩家或箱子站在踏板上时激活
- 激活后触发连接的门或机关
- 离开踏板后可选：保持激活/立即重置

**属性定义**：
| 属性 | 类型 | 默认值 | 说明 |
|-----|------|-------|------|
| `stay_active` | bool | false | 离开后是否保持激活 |
| `activation_delay` | float | 0.0 | 激活延迟时间(秒) |
| `deactivation_delay` | float | 0.0 | 失活延迟时间(秒) |
| `required_weight` | int | 1 | 需要的重量等级 |

**信号**：
- `activated()` - 踏板被激活
- `deactivated()` - 踏板失活

**视觉反馈**：
- 未激活：暗淡颜色
- 激活中：渐亮动画
- 已激活：亮起颜色

---

### 3.2 开关门 (SwitchDoor)

**功能描述**：
- 可由开关、踏板或其他谜题控制
- 支持多种门类型：单向门、双向门、隐藏门
- 开关状态与门状态同步

**门类型枚举**：
```gdscript
enum DoorType {
    SLIDING,      # 滑动门
    ROTATING,     # 旋转门
    DISAPPEARING, # 消失门
    LOCKED        # 需要钥匙的门
}
```

**属性定义**：
| 属性 | 类型 | 默认值 | 说明 |
|-----|------|-------|------|
| `door_type` | DoorType | SLIDING | 门的类型 |
| `is_open` | bool | false | 当前是否开启 |
| `open_direction` | Vector2 | (0, -1) | 开启方向 |
| `open_distance` | float | 64.0 | 开启移动距离 |
| `animation_speed` | float | 0.3 | 动画速度(秒) |

**方法**：
- `open()` - 开门
- `close()` - 关门
- `toggle()` - 切换状态

---

### 3.3 推拉箱子 (PushableBox)

**功能描述**：
- 玩家可以推动箱子
- 箱子有重量属性，影响踏板激活
- 箱子可以叠放

**属性定义**：
| 属性 | 类型 | 默认值 | 说明 |
|-----|------|-------|------|
| `weight` | int | 1 | 重量等级 |
| `push_speed` | float | 100.0 | 推动速度 |
| `can_be_pulled` | bool | false | 是否可以拉动 |
| `is_pushable` | bool | true | 当前是否可推动 |

**交互逻辑**：
1. 玩家靠近箱子按下互动键
2. 进入推动状态，箱子随玩家移动
3. 再次按下互动键或远离时停止推动

---

## 四、场景配置

### 4.1 迷宫关卡谜题布局

在 `maze_level.tscn` 中添加谜题区域：

```
Puzzles/
├── PuzzleArea1/
│   ├── Plate1 (PressurePlate)
│   ├── Plate2 (PressurePlate)
│   └── Door1 (SwitchDoor)
├── PuzzleArea2/
│   ├── Box1 (PushableBox)
│   ├── Plate3 (PressurePlate)
│   └── Door2 (SwitchDoor)
└── PuzzleArea3/
    ├── Switch1 (ToggleSwitch)
    └── Door3 (SwitchDoor)
```

### 4.2 谜题连接配置

使用 `puzzle_id` 建立连接关系：
- 踏板的 `target_id` → 门的 `puzzle_id`
- 开关的 `target_id` → 门的 `puzzle_id`
- 支持一个控制器连接多个门

---

## 五、实现文件清单

| 文件路径 | 说明 | 依赖 |
|---------|------|------|
| `scripts/puzzles/puzzle_base.gd` | 谜题基类 | 无 |
| `scripts/puzzles/pressure_plate.gd` | 压力踏板 | puzzle_base |
| `scripts/puzzles/switch_door.gd` | 开关门 | puzzle_base |
| `scripts/puzzles/pushable_box.gd` | 推拉箱子 | 无 |
| `scripts/puzzles/toggle_switch.gd` | 拨动开关 | puzzle_base |

---

## 六、与现有系统的集成

### 6.1 睡眠阶段集成
- 某些谜题只在特定阶段可解（`required_stage`）
- REM期可能有特殊解谜方式（情感共鸣）

### 6.2 玩家系统集成
- 玩家推动箱子时进入特殊状态
- 解谜成功时触发HUD提示

### 6.3 存档系统集成
- 谜题状态需要保存到存档
- 重置游戏时重置所有谜题

---

## 七、实现顺序

1. **阶段1**: 实现基类和压力踏板
2. **阶段2**: 实现开关门
3. **阶段3**: 实现推拉箱子
4. **阶段4**: 场景中添加谜题实例并测试

---

**文档版本**: 1.0  
**更新记录**:
- 2026-04-20: 初始版本创建

# 《影梦》(Silhouette Dream) 角色ID命名规范

本文档定义游戏中所有角色的唯一标识符（ID）命名规则，用于程序开发中的角色引用和数据管理。

---

## 格式说明

```
[类型]_[角色名]_[序号]
```

---

## 类型定义

| 类型代码 | 全称 | 说明 |
|---------|------|------|
| `CHAR` | Character | 主角角色，玩家可直接操控 |
| `NPC` | Non-Player Character | 非玩家角色，由AI控制 |
| `BOSS` | Boss | BOSS级敌人（预留） |
| `MOB` | Mob | 普通怪物（预留） |

---

## 角色名缩写

| 缩写 | 对应角色 | 说明 |
|-----|---------|------|
| `BOY` | 小男孩 | 现实中的主角 |
| `SHADOW` | 影子 | 梦境中的主角 |
| `BEAR` | 小熊 | 寻找心脏的泰迪熊 |
| `DOCTOR` | 医生 | 梦境免疫系统管理员 |
| `WITCH` | 魔女 | 幽灵引导者 |

---

## 序号规则

- **格式**：3位数字，从 `001` 开始
- **用途**：区分同一角色的不同形态或版本
- **示例**：
  - `CHAR_SHADOW_001` = 影子基础形态
  - `CHAR_SHADOW_002` = 影子觉醒形态（预留）
  - `NPC_WITCH_001` = 魔女幽灵形态
  - `NPC_WITCH_002` = 魔女本体形态（预留）

---

## 当前角色ID列表

| 角色ID | 角色名称 | 类型 |
|--------|---------|------|
| `CHAR_BOY_001` | 小男孩 | 主角 |
| `CHAR_SHADOW_001` | 影子 | 主角 |
| `NPC_BEAR_001` | 寻找心脏的小熊 | NPC |
| `NPC_DOCTOR_001` | 医生 | NPC |
| `NPC_WITCH_001` | 魔女 | NPC |

---

## 使用示例

### Godot 代码示例

```gdscript
# 角色ID常量定义
const CHAR_BOY_001 = "CHAR_BOY_001"
const CHAR_SHADOW_001 = "CHAR_SHADOW_001"
const NPC_BEAR_001 = "NPC_BEAR_001"
const NPC_DOCTOR_001 = "NPC_DOCTOR_001"
const NPC_WITCH_001 = "NPC_WITCH_001"

# 获取角色数据
func get_character_data(character_id: String):
    match character_id:
        CHAR_BOY_001:
            return load("res://characters/boy/boy_data.tres")
        CHAR_SHADOW_001:
            return load("res://characters/shadow/shadow_data.tres")
        NPC_BEAR_001:
            return load("res://characters/bear/bear_data.tres")
        NPC_DOCTOR_001:
            return load("res://characters/doctor/doctor_data.tres")
        NPC_WITCH_001:
            return load("res://characters/witch/witch_data.tres")
        _:
            push_error("未知角色ID: " + character_id)
            return null

# 检查角色类型
func is_player_character(character_id: String) -> bool:
    return character_id.begins_with("CHAR_")

func is_npc(character_id: String) -> bool:
    return character_id.begins_with("NPC_")
```

### 数据表引用示例

```json
{
    "dialogue_id": "dlg_001",
    "speaker": "NPC_WITCH_001",
    "text": "你终于来了，我等你很久了...",
    "emotion": "mysterious"
}
```

---

## 扩展指南

添加新角色时，请遵循以下步骤：

1. **确定类型**：选择 `CHAR`、`NPC`、`BOSS` 或 `MOB`
2. **定义缩写**：使用3-6个大写字母表示角色名
3. **分配序号**：从 `001` 开始，同角色不同形态递增
4. **更新文档**：在本文件的"当前角色ID列表"中添加新条目
5. **同步代码**：在游戏的常量定义文件中添加对应ID

---

**关联文档**：[角色设定.md](角色设定.md)（本文档的父文档）

*注：本文档为《影梦》(Silhouette Dream) 游戏的角色ID命名规范。*

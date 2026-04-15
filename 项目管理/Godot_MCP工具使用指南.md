# Godot MCP 工具使用指南

> **文档版本**：1.0
> **创建日期**：2026年4月14日
> **适用范围**：所有 AI Agent（Agent A、Agent B、Agent C）
> **最后更新**：2026年4月14日

---

## 📋 概述

本项目已集成 **godot-mcp**（Model Context Protocol）服务器，为 AI 助手提供对 Godot 4.x 游戏引擎的完整控制能力。通过 MCP 协议，AI Agent 可以直接操控 Godot 引擎、执行 GDScript 代码、操作场景文件、管理项目资源等。

### 核心优势

- ✅ **149 个专用工具** - 覆盖 Godot 开发的方方面面
- ✅ **无需手动操作** - AI 可自主完成场景创建、代码编写、调试运行
- ✅ **运行时交互** - 支持游戏运行时的实时检查和修改
- ✅ **完全免费** - MIT 许可证，无使用限制

---

## 🚀 快速开始

### 环境要求

- **Godot Engine**：4.x 版本（推荐 4.4+）
- **Node.js**：>= 18.0.0
- **MCP 客户端**：Claude Code、Cursor、Cline、Trae IDE 等

### MCP 服务器状态

✅ **已配置并就绪**

- **安装位置**：`/Users/qiufu/AAA_GitHub_project/GAME_MAKING/godot-mcp`
- **MCP 配置**：`/Users/qiufu/.trae-cn/mcps/godot-mcp/mcp-config.json`
- **Godot 路径**：已自动检测（`/Applications/Godot.app`）

### 激活 MCP 服务器

如果 MCP 服务器未自动启动，请在 Trae IDE 设置中启用 godot-mcp 插件。

---

## 🛠️ 工具分类与使用场景

### 1️⃣ 项目管理（7 个工具）

**使用场景**：启动编辑器、运行项目、获取版本信息

```
Agent A: "检查当前 Godot 版本和项目配置"
Agent B: "启动 Godot 编辑器打开我们的项目"
Agent C: "查看项目的元数据和基本信息"
```

| 工具 | 功能 | 示例请求 |
|------|------|---------|
| `launch_editor` | 启动 Godot 编辑器 | "打开项目的编辑器" |
| `run_project` | 运行项目并捕获输出 | "运行游戏测试最新改动" |
| `stop_project` | 停止运行中的项目 | "停止当前运行的实例" |
| `get_debug_output` | 获取控制台输出和错误 | "查看运行时的错误日志" |
| `get_godot_version` | 获取 Godot 版本 | "确认 Godot 4.4 是否可用" |
| `list_projects` | 查找目录中的项目 | "查找所有 Godot 项目" |
| `get_project_info` | 获取项目元数据 | "获取当前项目的配置信息" |

---

### 2️⃣ 场景管理（12 个工具）

**使用场景**：创建游戏场景、添加节点、管理场景结构

```
Agent B: "创建一个主角场景，包含 CharacterBody2D、Sprite2D 和 CollisionShape2D"
Agent B: "在主场景中添加一个敌人节点，使用 Area2D 作为巡逻敌人"
Agent A: "读取当前场景的完整结构，生成场景树文档"
```

**核心操作流程**：

```markdown
1. 创建场景
   → create_scene [root_node_type]

2. 添加节点
   → add_node [scene_path] [parent_path] [node_type]

3. 配置节点属性
   → game_set_property [node_path] [property] [value]

4. 附加脚本
   → attach_script [scene_path] [node_path] [script_path]

5. 保存场景
   → save_scene [scene_path]
```

---

### 3️⃣ 运行时代码执行（最强大功能）

**使用场景**：执行任意 GDScript 代码、获取运行时数据、动态修改游戏状态

```
Agent B: "执行 GDScript 获取主角的当前位置和速度"
Agent B: "在运行时修改玩家的速度为 400"
Agent A: "测试新的移动算法，观察返回值"
```

#### game_eval - 核心运行时工具

**功能**：在运行的游戏中执行任意 GDScript 代码并获取返回值

**使用示例**：

```markdown
# 获取玩家位置
"Execute: return $player.global_position"

# 获取玩家速度
"Execute: return $player.velocity"

# 修改玩家速度
"Execute: $player.velocity = Vector2(400, 300)"

# 调用自定义方法
"Execute: return $player.get_health()"

# 复杂逻辑
"Execute: |
    var health = $player.get_health()
    var max_health = $player.get_max_health()
    return {'health': health, 'max_health': max_health, 'percentage': health * 100 / max_health}"
```

#### game_get_property / game_set_property

**功能**：获取或设置任意节点属性

```markdown
# 获取属性
"Get the 'speed' property from the player node"
→ game_get_property("player", "speed")

# 设置属性
"Set the player's velocity to (100, 200)"
→ game_set_property("player", "velocity", Vector2(100, 200))
```

#### game_call_method

**功能**：调用任意节点的方法

```markdown
# 调用无参数方法
"Call the 'take_damage' method on the player with argument 10"
→ game_call_method("player", "take_damage", [10])

# 调用自定义方法
"Call 'update_inventory' method on inventory_system"
→ game_call_method("inventory_system", "update_inventory", ["sword", 1])
```

---

### 4️⃣ 运行时节点操作（7 个工具）

**使用场景**：动态创建/删除节点、切换场景、修改场景树结构

```
Agent B: "在运行时动态添加一个新的敌人"
Agent B: "切换到战斗场景"
Agent A: "测试场景切换的效果"
```

#### 动态场景操作

```markdown
# 实例化场景
"Add the enemy scene to the current game tree"
→ game_instantiate_scene("res://scenes/enemy.tscn")

# 删除节点
"Remove the old checkpoint from the tree"
→ game_remove_node("checkpoint_old")

# 切换场景
"Change to the boss room scene"
→ game_change_scene("res://scenes/boss_room.tscn")

# 重新分配父节点
"Move the player to the new parent"
→ game_reparent_node("player", "new_parent")
```

---

### 5️⃣ 2D 游戏专用工具

**使用场景**：TileMap 操作、2D 精灵管理、2D 物理、视差背景

根据《影梦》项目需求，以下工具尤为重要：

#### TileMap 操作（game_tilemap）

```markdown
# 获取单元格
"Get the tile at position (5, 3) in the floor layer"
→ game_tilemap("floor", "get", Vector2(5, 3))

# 设置单元格
"Set the wall tile at position (10, 8)"
→ game_tilemap("walls", "set", Vector2(10, 8), 1)

# 清除单元格
"Clear the tile at position (2, 2)"
→ game_tilemap("floor", "clear", Vector2(2, 2))
```

#### 2D 物理（game_physics_2d）

```markdown
# 点查询
"Check what tile is at world position (100, 200)"
→ game_physics_2d("world", "point_query", Vector2(100, 200))

# 区域查询
"Get all colliders in the area"
→ game_physics_2d("detection_area", "overlap_area", null)
```

#### 2D 绘制（game_canvas_draw）

```markdown
# 绘制调试线条
"Draw a line from player to target"
→ game_canvas_draw("line", {"from": player_pos, "to": target_pos, "color": Color.GREEN})

# 绘制调试矩形
"Draw a hitbox rectangle"
→ game_canvas_draw("rect", {"position": box_pos, "size": box_size, "color": Color.RED})
```

#### 视差背景（game_parallax）

```markdown
# 配置视差层
"Set parallax layer 1 to scroll at 0.5x speed"
→ game_parallax("ParallaxBackground", "set_layer_speed", 1, 0.5)
```

---

### 6️⃣ 动画系统（12+ 个工具）

**使用场景**：角色动画控制、UI 动画、特效动画

#### AnimationPlayer 控制（game_play_animation）

```markdown
# 播放动画
"Play the 'walk' animation on the player"
→ game_play_animation("player", "play", "walk")

# 停止动画
"Stop all animations on the enemy"
→ game_play_animation("enemy", "stop", null)

# 暂停动画
"Pause the 'attack' animation"
→ game_play_animation("player", "pause", "attack")
```

#### 创建动画（game_create_animation）

```markdown
# 创建新动画
"Create an animation with keyframes for position and scale"
→ game_create_animation("player", "special_attack", {
    "tracks": [
        {"type": "value", "property": "position", "keyframes": [0, 1, 2]},
        {"type": "value", "property": "scale", "keyframes": [0, 1.5, 1]}
    ]
})
```

#### 属性补间（game_tween_property）

```markdown
# 平滑移动
"Tween the player's position to (100, 200) over 0.5 seconds"
→ game_tween_property("player", "position", Vector2(100, 200), 0.5, "ease_in_out")

# 缩放动画
"Tween the enemy's scale to 1.5 over 0.3 seconds"
→ game_tween_property("enemy", "scale", Vector2(1.5, 1.5), 0.3, "ease_out")
```

---

### 7️⃣ UI 系统（8+ 个工具）

**使用场景**：HUD 显示、对话框、菜单系统、进度条

#### 文本操作（game_ui_text）

```markdown
# 设置文本
"Update the health label to show 100 HP"
→ game_ui_text("health_label", "set_text", "100 HP")

# 获取文本
"Get the current dialog text"
→ game_ui_text("dialog_text", "get_text", null)
```

#### 控件操作（game_ui_control）

```markdown
# 显示/隐藏控件
"Show the inventory panel"
→ game_ui_control("inventory_panel", "set_visible", true)

# 设置焦点
"Focus the name input field"
→ game_ui_control("name_input", "grab_focus", null)
```

#### 进度条（game_ui_range）

```markdown
# 设置进度值
"Update the health bar to 75%"
→ game_ui_range("health_bar", "set_value", 75)

# 获取当前值
"Get the current mana percentage"
→ game_ui_range("mana_bar", "get_value", null)
```

---

### 8️⃣ 敌人 AI 相关工具

**使用场景**：实现巡逻、追击、攻击等敌人行为

#### 射线检测（game_raycast）

```markdown
# 检测前方障碍
"Cast a ray forward from the enemy to detect walls"
→ game_raycast("enemy", "cast", {
    "origin": enemy_pos,
    "direction": forward,
    "length": 50
})

# 地面检测
"Check if the enemy is grounded"
→ game_raycast("enemy", "cast", {
    "origin": enemy_pos,
    "direction": DOWN,
    "length": 2
})
```

#### 区域查询（game_find_nodes_by_class）

```markdown
# 查找所有敌人
"Find all enemy nodes in the current scene"
→ game_find_nodes_by_class("enemy", null)

# 查找特定类型的节点
"Get all Area2D nodes (for detection zones)"
→ game_find_nodes_by_class("Area2D", null)
```

#### 节点分组（game_get_nodes_in_group）

```markdown
# 获取同组节点
"Get all enemies in the 'patrol' group"
→ game_get_nodes_in_group("patrol", null)

# 动态分组
"Add the new enemy to the 'active_enemies' group"
→ game_manage_group("enemy_001", "add", "active_enemies")
```

---

### 9️⃣ 音频系统（10+ 个工具）

**使用场景**：背景音乐、音效播放、混音控制

#### 音频播放（game_audio_play）

```markdown
# 播放背景音乐
"Play the dream world background music"
→ game_audio_play("BGM_Dream", "play", "res://audio/bgm/dream_world.ogg")

# 播放音效
"Play the sword swing sound effect"
→ game_audio_play("SFX_Player", "play", "res://audio/sfx/sword_swing.wav")

# 停止音效
"Stop the footstep sound"
→ game_audio_play("SFX_Footstep", "stop", null)
```

#### 音频总线控制（game_audio_bus）

```markdown
# 设置音量
"Set the music volume to 50%"
→ game_audio_bus("Master", "set_volume", 0.5)

# 静音
"Mute all sound effects"
→ game_audio_bus("SFX", "set_mute", true)
```

---

### 🔟 文件操作（4 个工具）

**使用场景**：读取配置、写入数据、创建目录

#### 基础文件操作

```markdown
# 读取文件
"Read the player configuration file"
→ read_file("res://config/player_config.json")

# 写入文件
"Save the game progress"
→ write_file("user://savegame.json", save_data)

# 创建目录
"Create the new level directory"
→ create_directory("res://levels/level_05")
```

#### 项目文件管理

```markdown
# 列出项目文件
"List all GDScript files in the project"
→ list_project_files("*.gd")

# 过滤资源文件
"Find all scene files"
→ list_project_files("*.tscn")
```

---

## 📝 Agent 特定使用指南

### Agent A（程序编程需求分析师）

#### 主要职责
- 分析游戏需求并转化为技术规格
- 设计系统架构和接口
- 编写技术文档

#### 推荐使用工具

| 优先级 | 工具类别 | 使用场景 |
|--------|----------|----------|
| 🔴 高 | `read_scene`, `list_project_files` | 分析现有场景结构 |
| 🔴 高 | `read_project_settings` | 了解项目配置 |
| 🔴 高 | `get_debug_output` | 捕获错误和分析问题 |
| 🟡 中 | `game_eval` | 验证算法逻辑 |
| 🟡 中 | `read_file`, `write_file` | 读取/写入配置数据 |

#### 示例工作流

```markdown
1. 分析现有代码
   "读取所有 GDScript 文件，分析当前的场景结构"
   → list_project_files("*.gd")
   → read_scene("res://scenes/main.tscn")

2. 验证需求实现
   "测试新的敌人 AI 行为是否正确"
   → run_project()
   → game_eval("return $enemy.get_state()")

3. 记录技术规格
   "将当前敌人 AI 的状态机结构记录到文档"
   → write_file("docs/enemy_ai_spec.md", state_machine_doc)
```

---

### Agent B（插件脚本开发工程师）

#### 主要职责
- 实现游戏核心系统和功能
- 编写高质量的 GDScript 代码
- 调试和优化性能

#### 推荐使用工具

| 优先级 | 工具类别 | 使用场景 |
|--------|----------|----------|
| 🔴 高 | `create_scene`, `add_node` | 创建游戏场景 |
| 🔴 高 | `game_set_property`, `game_call_method` | 调试和测试代码 |
| 🔴 高 | `game_play_animation`, `game_tween_property` | 动画系统实现 |
| 🔴 高 | `game_spawn_node`, `game_remove_node` | 动态对象管理 |
| 🟡 中 | `game_raycast`, `game_physics_2d` | 物理和碰撞检测 |
| 🟡 中 | `game_audio_play`, `game_audio_bus` | 音频系统集成 |
| 🟡 中 | `game_ui_*` 系列 | UI 系统实现 |
| 🟢 低 | `game_debug_draw` | 调试可视化 |

#### 示例工作流

```markdown
1. 创建场景结构
   "创建主角场景：CharacterBody2D + Sprite2D + CollisionShape2D + AnimationPlayer"
   → create_scene("res://scenes/player.tscn", "CharacterBody2D")
   → add_node("res://scenes/player.tscn", "/root/player", "Sprite2D")
   → add_node("res://scenes/player.tscn", "/root/player", "CollisionShape2D")
   → add_node("res://scenes/player.tscn", "/root/player", "AnimationPlayer")

2. 编写脚本
   "创建移动脚本"
   → write_file("res://scripts/player_movement.gd", movement_script)
   → attach_script("res://scenes/player.tscn", "/root/player", "res://scripts/player_movement.gd")

3. 测试运行
   "运行游戏测试移动控制"
   → run_project()
   → game_eval("return $player.velocity")

4. 调试迭代
   "修改速度并重新测试"
   → game_set_property("player", "velocity", Vector2(400, 300))
   → game_eval("return $player.get_speed()")
```

---

### Agent C（美术音频设计师）

#### 主要职责
- 创建游戏美术资源
- 制作音效和背景音乐
- 设计 UI 界面

#### 推荐使用工具

| 优先级 | 工具类别 | 使用场景 |
|--------|----------|----------|
| 🔴 高 | `list_project_files` | 查看现有资源 |
| 🔴 高 | `read_file` | 了解资源需求规格 |
| 🟡 中 | `game_screenshot` | 截图对比效果 |
| 🟡 中 | `game_set_property` | 调整精灵属性 |
| 🟢 低 | `game_canvas_draw` | 调试绘制效果 |

#### 示例工作流

```markdown
1. 查看资源需求
   "读取美术资源规格文档"
   → read_file("res://docs/art_resource_spec.md")

2. 预览效果
   "运行游戏查看精灵显示效果"
   → run_project()
   → game_screenshot()

3. 调整参数
   "修改精灵的缩放和调制颜色"
   → game_set_property("player_sprite", "modulate", Color(1.2, 1.2, 1.0))
   → game_set_property("player_sprite", "scale", Vector2(2.0, 2.0))
```

---

## 🎯 最佳实践

### 1️⃣ 使用自然语言请求

**推荐**：
```markdown
"创建一个包含角色身体、精灵和碰撞体的主角场景"

"为主角添加跳跃和移动的 GDScript 脚本"

"在运行时获取所有敌人的位置信息"
```

**不推荐**：
```markdown
"使用 create_scene 工具创建 CharacterBody2D 场景"
```

### 2️⃣ 分步骤操作

**复杂任务分解**：

```markdown
# ❌ 一步完成所有操作
"创建完整的主角场景，包含所有组件、脚本和动画"

# ✅ 分步骤完成
1. "创建主角场景根节点"
2. "添加 Sprite2D 和 CollisionShape2D 子节点"
3. "编写并附加移动脚本"
4. "添加待机动画"
```

### 3️⃣ 利用 MCP 工具获取上下文

**在开始编写代码前**：

```markdown
"先读取现有场景结构，了解节点层级"
→ read_scene("res://scenes/main.tscn")

"查看项目的输入映射配置"
→ manage_input_map("list", null)

"了解当前项目设置"
→ read_project_settings()
```

### 4️⃣ 运行时调试

**开发和测试阶段**：

```markdown
# 使用 game_eval 测试逻辑
"测试伤害计算公式"
→ game_eval("return 100 * 1.5 - 20")

# 实时查看状态
"获取敌人当前状态"
→ game_eval("return $enemy.get_current_state()")

# 动态修改参数
"调整角色移动速度进行测试"
→ game_set_property("player", "speed", 500)
```

### 5️⃣ 善用离线操作

**无需运行游戏**：

```markdown
"修改场景文件中的节点属性"
→ modify_scene_node("res://scenes/level1.tscn", "player", {"position": Vector2(100, 200)})

"读取项目配置文件"
→ read_project_settings()

"创建新的资源文件"
→ create_resource("res://resources/player_stats.tres", "Resource")
```

---

## ⚠️ 注意事项

### 环境要求

1. **Godot 引擎必须安装**
   - 确保 `/Applications/Godot.app` 存在
   - 或设置 `GODOT_PATH` 环境变量指向正确路径

2. **MCP 服务器配置**
   - 确保 MCP 配置文件正确
   - 必要时重启 Trae IDE 以加载配置

### 运行时工具限制

使用 `game_*` 运行时工具需要：

1. **游戏必须处于运行状态**
   ```markdown
   # 先运行游戏
   → run_project()

   # 然后才能使用运行时工具
   → game_eval("return $player.position")
   ```

2. **MCP Interaction Server Autoload**
   - 复制 `godot-mcp/build/scripts/mcp_interaction_server.gd` 到项目
   - 在 Godot 中注册为 Autoload（名称：`McpInteractionServer`）
   - 服务器监听 `127.0.0.1:9090`

### 路径规范

- **绝对路径**：`res://scenes/main.tscn`（推荐）
- **用户路径**：`user://savegame.json`
- **文件系统路径**：`/Users/qiufu/project/`

### 错误处理

```markdown
# 查看错误日志
"获取运行时的所有错误"
→ game_get_errors()

# 查看打印输出
"查看游戏的调试打印"
→ game_get_logs()

# 获取详细错误信息
"获取最新的错误详情"
→ get_debug_output()
```

---

## 📚 参考资源

### 官方文档

- **Godot 文档**：https://docs.godotengine.org/
- **MCP 协议**：https://modelcontextprotocol.io/
- **godot-mcp GitHub**：https://github.com/tugcantopaloglu/godot-mcp

### 中文文档

- **安装指南**：`/Users/qiufu/AAA_GitHub_project/GAME_MAKING/godot-mcp/安装指南.md`
- **中文 README**：`/Users/qiufu/AAA_GitHub_project/GAME_MAKING/godot-mcp/README-zh.md`

### 本地文件

| 文件 | 位置 | 用途 |
|------|------|------|
| godot-mcp 源码 | `/Users/qiufu/AAA_GitHub_project/GAME_MAKING/godot-mcp` | 查看工具实现 |
| MCP 配置 | `/Users/qiufu/.trae-cn/mcps/godot-mcp/mcp-config.json` | MCP 服务器配置 |
| MCP Autoload | `godot-mcp/build/scripts/mcp_interaction_server.gd` | 运行时交互脚本 |

---

## 🆘 故障排除

### MCP 服务器未启动

**症状**：无法使用 godot-mcp 工具

**解决**：
1. 检查 MCP 配置：`cat ~/.trae-cn/mcps/godot-mcp/mcp-config.json`
2. 重启 Trae IDE
3. 手动启动 MCP 服务器：
   ```bash
   node /Users/qiufu/AAA_GitHub_project/GAME_MAKING/godot-mcp/build/index.js
   ```

### Godot 未检测到

**症状**：工具提示 "Godot not found"

**解决**：
1. 确认 Godot 已安装：`ls /Applications/Godot.app`
2. 设置环境变量：
   ```bash
   export GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot"
   ```

### 运行时工具不工作

**症状**：`game_eval` 返回错误或超时

**解决**：
1. 确认游戏正在运行：`run_project()`
2. 检查 MCP Interaction Server Autoload 是否添加
3. 检查端口 9090 是否被占用：`lsof -i :9090`

### 场景文件操作失败

**症状**：`read_scene` 或 `modify_scene_node` 返回错误

**解决**：
1. 确认文件路径正确
2. 检查文件是否存在
3. 验证场景文件格式（.tscn）

---

## 📝 更新记录

| 日期 | 版本 | 更新内容 |
|------|------|----------|
| 2026-04-14 | 1.0 | 初始版本，集成 godot-mcp |

---

**文档维护**：所有 AI Agent 均有责任维护本文档，如有更新请标注版本和日期。

*注：本指南旨在帮助 AI Agent 高效使用 godot-mcp 工具，具体实现应根据实际项目需求调整。*

## Why

《影梦》项目目前面临最大阻塞点：核心玩法机制尚未确定。虽然已有完整的世界观、美术风格和角色设定，但"玩家到底在玩什么"还不清晰。团队经验有限，需要一个简单但有效的核心玩法来推动第二阶段开发。

## What Changes

- 确定核心体验类型：**探索解谜导向**（去掉战斗）
- 定义四个睡眠阶段的具体玩法（无战斗，以探索、躲避、解谜为主）
- 设计极简玩家操作方案（适合新手团队实现）
- 更新现有玩法设定文档，移除战斗相关内容

## Capabilities

### New Capabilities

- `core-gameplay-loop`: 定义游戏核心循环（探索→收集→解谜→推进剧情）
- `sleep-stage-mechanics`: 四个睡眠阶段的具体玩法设计
- `player-controls`: 极简玩家操作设计
- `enemy-non-combat`: 非战斗型敌人设计（巡逻、追踪、躲避）
- `puzzle-simple`: 简单解谜机制设计

### Modified Capabilities

- 修改现有`mechanics.md`文档，移除战斗相关内容

## Impact

- **受影响文档**：[游戏性设定文档](file:///Users/qiufu/AAA_GitHub_project/GAME_MAKING/docs/design/gameplay/mechanics.md)
- **Agent A**：可以开始编写程序需求文档
- **Agent C**：可以开始美术资源规格书（不需要战斗动画）
- **技术实现**：Godot 4.x，适合新手团队

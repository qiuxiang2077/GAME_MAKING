## Why

项目初始化阶段缺少标准的目录结构，导致：
1. Agent D无法存放草稿和聊天记录
2. OpenSpec变更无法归档（缺少archive目录）
3. 未来Godot项目目录不规范

建立清晰的目录结构是后续开发的基础。

## What Changes

- 创建 `草稿/` 目录（存放Agent D的临时文件）
- 创建 `openspec/specs/` 目录（存放能力规格）
- 创建 `openspec/archive/` 目录（存放归档变更）
- 创建 `Godot项目/` 目录结构（addons, assets, src, scenes）

## Capabilities

### New Capabilities
- `project-structure`: 项目目录结构规范

### Modified Capabilities
- 无

## Impact

- 所有Agent的工作目录
- OpenSpec变更管理流程
- 未来的Godot开发工作流

## Context

当前项目缺少标准目录结构，影响Agent协作和OpenSpec工作流。

## Goals / Non-Goals

**Goals:**
- 创建Agent D需要的`草稿/`目录
- 完善OpenSpec目录结构（specs/, archive/）
- 预创建Godot项目目录

**Non-Goals:**
- 不创建实际的Godot项目文件
- 不迁移现有文件

## Decisions

- 使用中文目录名（`草稿/`, `Godot项目/`）保持与现有结构一致
- Godot项目使用标准结构：addons/, assets/, src/, scenes/

## Risks / Trade-offs

- [Risk] 目录名中文可能在某些工具中兼容性问题 → 使用英文别名或符号链接

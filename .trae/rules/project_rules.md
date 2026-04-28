# 项目规则 - 《影梦》

## 核心原则

1. **文档优先**：变更先更新文档，再执行实现
2. **Agent路由**：
   - 创意整理 → Agent D
   - 技术需求 → Agent A
   - 代码实现 → Agent B
   - 美术资源 → Agent C
3. **OpenSpec工作流**：探索(`/opsx:explore`)→提案→执行→归档

## 目录规范

```
GAME_MAKING/
├── game/               # Godot游戏项目（开这个目录跑游戏）
│   ├── scenes/         # Godot场景
│   ├── scripts/        # GDScript
│   ├── ui/             # UI系统
│   └── project.godot   # 项目文件
├── development/        # 开发辅助
│   ├── docs/           # 文档（设定.md、agents.md、tech/）
│   ├── wiki/           # 游戏百科HTML
│   ├── openspec/       # 变更管理
│   └── README.md       # 项目说明
├── .trae/              # AI规则（隐藏）
└── LICENSE
```

## Agent协作

| 阶段 | Agent | 输入 → 输出 |
|-----|-------|-----------|
| 准备 | D | 聊天记录 → 设定数据库 |
| 编码 | A→B+C | 设定 → 需求/代码/美术 |
| 瓶颈 | OpenSpec+A | 问题 → 决策方案 |

> Agent详情见 [dev/docs/agents.md](file:///Users/qiufu/AAA_GitHub_project/GAME_MAKING/dev/docs/agents.md)

## 关键规则

- **复杂功能**：先用`/opsx:explore`思考，再实现
- **设定变更**：检查一致性，更新Wiki
- **代码规范**：snake_case，文件<300行，注释完整
- **性能目标**：60FPS，单元测试>80%

## 禁止事项

1. 跳过文档直接编码
2. 多Agent并行工作
3. 猜测用户意图（不确定时询问）
4. 跳过测试

## 质量检查

- [ ] 文档已更新
- [ ] 测试通过
- [ ] 代码符合规范
- [ ] 无设定冲突

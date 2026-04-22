extends Area2D

var collected = false

@onready var visual = $Visual if has_node("Visual") else null
@onready var glow = $Glow if has_node("Glow") else null

func _ready():
	# 连接碰撞信号
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body and body.name == "Player" and not collected:
		collect()

func collect():
	collected = true
	print("记忆碎片收集！")
	
	# 视觉反馈 - 创建一个闪烁效果
	if visual:
		var tween = create_tween()
		
		# 快速闪烁和放大
		for i in range(3):
			tween.tween_property(visual, "scale", Vector2(1.5, 1.5), 0.1)
			tween.tween_property(visual, "scale", Vector2(1.0, 1.0), 0.1)
			tween.tween_property(visual, "color", Color(1, 1, 1, 1), 0.05)
			tween.tween_property(visual, "color", Color(1, 0.9, 0.1, 1), 0.05)
		
		# 消失效果
		tween.tween_property(visual, "scale", Vector2(0.1, 0.1), 0.3)
		tween.tween_property(visual, "color:a", 0.0, 0.3)
	
	if glow:
		var tween2 = create_tween()
		tween2.tween_property(glow, "scale", Vector2(0.1, 0.1), 0.3)
		tween2.tween_property(glow, "color:a", 0.0, 0.3)
	
	# 禁用碰撞
	set_deferred("monitoring", false)
	
	# 增加分数或触发事件（使用兼容接口）
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager and game_manager.has_method("collect_memory"):
		game_manager.collect_memory("Found a memory fragment")
	elif game_manager and game_manager.has_method("add_memory_fragment"):
		game_manager.add_memory_fragment()

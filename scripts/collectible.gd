extends Area2D

var collected = false

func _ready():
	# 连接碰撞信号
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player" and not collected:
		collect()

func collect():
	collected = true
	print("记忆碎片收集！")
	
	# 视觉反馈 - 创建一个闪烁效果
	var tween = create_tween()
	
	# 快速闪烁和放大
	for i in range(3):
		tween.tween_property($Visual, "scale", Vector2(1.5, 1.5), 0.1)
		tween.tween_property($Visual, "scale", Vector2(1.0, 1.0), 0.1)
		tween.tween_property($Visual, "color", Color(1, 1, 1, 1), 0.05)
		tween.tween_property($Visual, "color", Color(1, 0.9, 0.1, 1), 0.05)
	
	# 消失效果
	tween.tween_property($Visual, "scale", Vector2(0.1, 0.1), 0.3)
	tween.tween_property($Glow, "scale", Vector2(0.1, 0.1), 0.3)
	tween.tween_property($Visual, "color:a", 0.0, 0.3)
	tween.tween_property($Glow, "color:a", 0.0, 0.3)
	
	# 禁用碰撞
	set_deferred("monitoring", false)
	
	# 增加分数或触发事件
	GameManager.add_memory_fragment()

extends Area2D

var collected = false

func _ready():
	# 连接碰撞信号
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player" and not collected:
		# 收集记忆碎片
		collected = true
		print("Memory fragment collected!")
		
		# 视觉反馈
		$ColorRect.color = Color(0, 0, 0, 0)  # 隐藏
		
		# 禁用碰撞
		set_deferred("monitoring", false)
		
		# 这里可以添加收集音效和分数系统

extends CharacterBody2D

# 小熊BOSS设定
var sanity_restore_amount = 40
var can_restore = true
var restore_cooldown = 8.0  # 秒
var restore_timer = 0.0

@onready var interaction_area = $InteractionArea

func _ready():
	add_to_group("boss")
	add_to_group("bear")
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)
	
	_apply_boss_color_mark()

func _process(delta):
	if restore_timer > 0:
		restore_timer -= delta

func interact():
	if can_restore:
		# 恢复玩家SAN值
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("restore_sanity"):
			player.restore_sanity(sanity_restore_amount)
			print("小熊安慰了玩家，恢复 " + str(sanity_restore_amount) + " SAN值")
			can_restore = false
			restore_timer = restore_cooldown
			_show_comfort_effect()
		else:
			print("无法找到玩家或玩家没有restore_sanity方法")
	else:
		print("安慰技能冷却中，剩余时间: " + str(restore_timer))

func _show_comfort_effect():
	# 简单的视觉反馈
	var tween = create_tween()
	if has_node("Visual"):
		var visual = $Visual
		tween.tween_property(visual, "scale", Vector2(1.3, 1.3), 0.2)
		tween.tween_property(visual, "scale", Vector2(1.0, 1.0), 0.2)
		# 也许还可以播放爱心粒子效果

func _on_body_entered(body):
	if body.is_in_group("player"):
		# 显示互动提示
		body.interactable_nearby = self

func _on_body_exited(body):
	if body.is_in_group("player"):
		body.interactable_nearby = null

func _on_restore_cooldown_timeout():
	can_restore = true
	print("小熊安慰技能已就绪")

func _apply_boss_color_mark():
	# 小熊BOSS颜色标记：温暖舒适主题（棕/黄/粉）
	print("应用小熊BOSS颜色标记...")
	
	# 1. 设置主体颜色
	if has_node("Visual"):
		var visual = $Visual
		visual.modulate = Color(0.6, 0.4, 0.2)  # 棕色，泰迪熊颜色
		print("小熊视觉节点颜色已设置")
	else:
		print("警告：小熊BOSS没有Visual节点，将创建简单标记")
		_create_simple_bear_mark()
	
	# 2. 创建简单的颜色标记（即使没有纹理也能显示）
	_create_bear_color_marks()

func _create_simple_bear_mark():
	# 创建一个简单的矩形作为小熊标记
	var mark = ColorRect.new()
	mark.name = "BearMark"
	mark.size = Vector2(50, 50)
	mark.color = Color(0.6, 0.4, 0.2, 0.8)  # 棕色
	mark.position = Vector2(-25, -25)  # 居中
	add_child(mark)
	print("创建简单小熊标记")

func _create_bear_color_marks():
	# 创建爱心标记（象征情感支持）
	if not has_node("HeartMark"):
		# 使用两个三角形组成爱心形状
		var heart_left = ColorRect.new()
		heart_left.name = "HeartLeft"
		heart_left.size = Vector2(20, 20)
		heart_left.color = Color(1, 0.6, 0.8)  # 粉色
		heart_left.position = Vector2(-15, -25)
		heart_left.rotation = deg_to_rad(-45)
		add_child(heart_left)
		
		var heart_right = ColorRect.new()
		heart_right.name = "HeartRight"
		heart_right.size = Vector2(20, 20)
		heart_right.color = Color(1, 0.6, 0.8)  # 粉色
		heart_right.position = Vector2(5, -25)
		heart_right.rotation = deg_to_rad(45)
		add_child(heart_right)
		
		# 添加脉动效果
		var tween = create_tween().set_loops()
		tween.tween_property(heart_left, "scale", Vector2(1.2, 1.2), 0.8)
		tween.parallel().tween_property(heart_right, "scale", Vector2(1.2, 1.2), 0.8)
		tween.tween_property(heart_left, "scale", Vector2(1.0, 1.0), 0.8)
		tween.parallel().tween_property(heart_right, "scale", Vector2(1.0, 1.0), 0.8)
		print("创建爱心标记")
	
	# 创建温暖光晕效果
	if not has_node("BearGlow"):
		var glow = ColorRect.new()
		glow.name = "BearGlow"
		glow.size = Vector2(80, 80)
		glow.color = Color(1, 0.8, 0.4, 0.2)  # 半透明暖黄色
		glow.position = Vector2(-40, -40)
		add_child(glow)
		
		# 呼吸效果
		var tween = create_tween().set_loops()
		tween.tween_property(glow, "scale", Vector2(1.15, 1.15), 1.5)
		tween.tween_property(glow, "scale", Vector2(1.0, 1.0), 1.5)
		print("创建小熊光晕效果")
	
	# 创建胸口空洞的发光效果（根据设定）
	if not has_node("ChestGlow"):
		var chest_glow = ColorRect.new()
		chest_glow.name = "ChestGlow"
		chest_glow.size = Vector2(25, 25)
		chest_glow.color = Color(1, 0.9, 0.3, 0.6)  # 金色发光
		chest_glow.position = Vector2(-12.5, 0)  # 胸口位置
		add_child(chest_glow)
		
		# 脉动效果，象征心跳
		var tween = create_tween().set_loops()
		tween.tween_property(chest_glow, "scale", Vector2(1.3, 1.3), 0.8)
		tween.tween_property(chest_glow, "scale", Vector2(1.0, 1.0), 0.8)
		tween.tween_property(chest_glow, "color:a", 0.8, 0.4)
		tween.tween_property(chest_glow, "color:a", 0.6, 0.4)
		print("创建胸口发光效果")
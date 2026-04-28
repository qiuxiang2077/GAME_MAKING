extends CharacterBody2D

# 医生BOSS设定
var healing_amount = 30
var can_heal = true
var heal_cooldown = 5.0  # 秒
var heal_timer = 0.0

@onready var interaction_area = $InteractionArea

func _ready():
	add_to_group("boss")
	add_to_group("doctor")
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)
	
	_apply_boss_color_mark()

func _process(delta):
	if heal_timer > 0:
		heal_timer -= delta

func interact():
	if can_heal:
		# 治疗玩家
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("heal"):
			player.heal(healing_amount)
			print("医生治疗了玩家，恢复 " + str(healing_amount) + " 生命值")
			can_heal = false
			heal_timer = heal_cooldown
			# 播放治疗动画或效果
			_show_heal_effect()
		else:
			print("无法找到玩家或玩家没有heal方法")
	else:
		print("治疗技能冷却中，剩余时间: " + str(heal_timer))

func _show_heal_effect():
	# 简单的视觉反馈
	var tween = create_tween()
	if has_node("Visual"):
		var visual = $Visual
		tween.tween_property(visual, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(visual, "scale", Vector2(1.0, 1.0), 0.1)

func _on_body_entered(body):
	if body.is_in_group("player"):
		# 显示互动提示
		body.interactable_nearby = self

func _on_body_exited(body):
	if body.is_in_group("player"):
		body.interactable_nearby = null

func _on_heal_cooldown_timeout():
	can_heal = true
	print("医生治疗技能已就绪")

func _apply_boss_color_mark():
	# 医生BOSS颜色标记：医疗主题（白/蓝/红）
	print("应用医生BOSS颜色标记...")
	
	# 1. 设置主体颜色
	if has_node("Visual"):
		var visual = $Visual
		visual.modulate = Color(0.9, 0.95, 1.0)  # 淡蓝色调，医疗感
		print("医生视觉节点颜色已设置")
	else:
		print("警告：医生BOSS没有Visual节点，将创建简单标记")
		_create_simple_doctor_mark()
	
	# 2. 创建简单的颜色标记（即使没有纹理也能显示）
	_create_doctor_color_marks()

func _create_simple_doctor_mark():
	# 创建一个简单的矩形作为医生标记
	var mark = ColorRect.new()
	mark.name = "DoctorMark"
	mark.size = Vector2(50, 50)
	mark.color = Color(0.9, 0.95, 1.0, 0.8)  # 淡蓝色
	mark.position = Vector2(-25, -25)  # 居中
	add_child(mark)
	print("创建简单医生标记")

func _create_doctor_color_marks():
	# 创建医疗十字标记
	if not has_node("MedicalCrossMark"):
		var cross = ColorRect.new()
		cross.name = "MedicalCrossMark"
		cross.size = Vector2(30, 10)  # 横条
		cross.color = Color(1, 0.2, 0.2)  # 红色
		cross.position = Vector2(-15, -20)
		add_child(cross)
		
		var cross_vertical = ColorRect.new()
		cross_vertical.name = "MedicalCrossVertical"
		cross_vertical.size = Vector2(10, 30)
		cross_vertical.color = Color(1, 0.2, 0.2)  # 红色
		cross_vertical.position = Vector2(-5, -25)
		add_child(cross_vertical)
		
		# 添加脉动效果
		var tween = create_tween().set_loops()
		tween.tween_property(cross, "color:a", 0.5, 1.0)
		tween.parallel().tween_property(cross_vertical, "color:a", 0.5, 1.0)
		tween.tween_property(cross, "color:a", 1.0, 1.0)
		tween.parallel().tween_property(cross_vertical, "color:a", 1.0, 1.0)
		print("创建医疗十字标记")
	
	# 创建红色光晕效果
	if not has_node("DoctorGlow"):
		var glow = ColorRect.new()
		glow.name = "DoctorGlow"
		glow.size = Vector2(80, 80)
		glow.color = Color(1, 0.3, 0.3, 0.2)  # 半透明红色
		glow.position = Vector2(-40, -40)
		add_child(glow)
		
		# 脉动效果
		var tween = create_tween().set_loops()
		tween.tween_property(glow, "scale", Vector2(1.1, 1.1), 1.5)
		tween.tween_property(glow, "scale", Vector2(1.0, 1.0), 1.5)
		print("创建医生光晕效果")
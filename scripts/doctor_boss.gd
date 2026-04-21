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
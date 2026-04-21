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
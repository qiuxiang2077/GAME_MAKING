class_name EmotionSystem
extends Node

enum EmotionType {
	ANXIETY,
	SADNESS,
	FEAR,
	ANGER,
	CALM
}

var enemy_emotions: Dictionary = {}
var emotion_labels: Dictionary = {}

signal emotion_revealed(enemy, emotion)
signal enemy_calmed(enemy)

func _ready():
	# 等待场景加载完成
	await get_tree().process_frame
	_scan_enemies()

func _scan_enemies():
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if not enemy_emotions.has(enemy):
			_assign_emotion(enemy)

func _assign_emotion(enemy):
	var emotions = [EmotionType.ANXIETY, EmotionType.SADNESS, EmotionType.FEAR, EmotionType.ANGER]
	var emotion = emotions[randi() % emotions.size()]
	enemy_emotions[enemy] = emotion

func reveal_emotions(stage: int):
	# 只在REM期显示情感
	if stage != 3:
		_hide_all_emotion_labels()
		return
	
	_scan_enemies()
	
	for enemy in enemy_emotions.keys():
		if is_instance_valid(enemy):
			_show_emotion_label(enemy)

func _show_emotion_label(enemy):
	if emotion_labels.has(enemy):
		return
	
	var label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.z_index = 60
	
	var emotion = enemy_emotions[enemy]
	match emotion:
		EmotionType.ANXIETY:
			label.text = "焦虑"
			label.add_theme_color_override("font_color", Color(0.9, 0.5, 0.2, 1))
		EmotionType.SADNESS:
			label.text = "悲伤"
			label.add_theme_color_override("font_color", Color(0.4, 0.5, 0.7, 1))
		EmotionType.FEAR:
			label.text = "恐惧"
			label.add_theme_color_override("font_color", Color(0.6, 0.2, 0.6, 1))
		EmotionType.ANGER:
			label.text = "愤怒"
			label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2, 1))
		EmotionType.CALM:
			label.text = "平静"
			label.add_theme_color_override("font_color", Color(0.3, 0.8, 0.5, 1))
	
	label.add_theme_font_size_override("font_size", 12)
	
	var root = get_tree().current_scene
	if root:
		root.add_child(label)
		emotion_labels[enemy] = label
		_update_label_position(enemy)
		
		emotion_revealed.emit(enemy, emotion)

func _hide_all_emotion_labels():
	for enemy in emotion_labels.keys():
		if is_instance_valid(emotion_labels[enemy]):
			emotion_labels[enemy].queue_free()
	emotion_labels.clear()

func _update_label_position(enemy):
	if emotion_labels.has(enemy) and is_instance_valid(enemy):
		var label = emotion_labels[enemy]
		label.position = enemy.global_position + Vector2(-20, -35)

func _process(delta):
	# 更新情感标签位置
	if not emotion_labels.is_empty():
		for enemy in emotion_labels.keys():
			if is_instance_valid(enemy) and is_instance_valid(emotion_labels[enemy]):
				_update_label_position(enemy)

func calm_enemy(enemy) -> bool:
	if not enemy_emotions.has(enemy):
		return false
	
	var emotion = enemy_emotions[enemy]
	
	# 移除情感标签
	if emotion_labels.has(enemy):
		if is_instance_valid(emotion_labels[enemy]):
			emotion_labels[enemy].queue_free()
		emotion_labels.erase(enemy)
	
	# 改变敌人状态为平静
	enemy_emotions[enemy] = EmotionType.CALM
	
	# 停止敌人攻击
	if enemy.has_method("reset_to_patrol"):
		enemy.reset_to_patrol()
	
	# 改变敌人视觉为平静状态
	if enemy.has_node("Visual"):
		var visual = enemy.get_node("Visual")
		var tween = create_tween()
		tween.tween_property(visual, "color", Color(0.3, 0.8, 0.5, 1), 0.5)
	
	enemy_calmed.emit(enemy)
	print("敌人被安抚: " + enemy.name)
	return true

func get_emotion_text(enemy) -> String:
	if not enemy_emotions.has(enemy):
		return "未知"
	
	match enemy_emotions[enemy]:
		EmotionType.ANXIETY: return "焦虑"
		EmotionType.SADNESS: return "悲伤"
		EmotionType.FEAR: return "恐惧"
		EmotionType.ANGER: return "愤怒"
		EmotionType.CALM: return "平静"
		_: return "未知"

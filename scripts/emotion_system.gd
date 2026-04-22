class_name EmotionSystem
extends Node

enum EmotionType {
	ANXIETY,
	SADNESS,
	FEAR,
	ANGER,
	CALM
}

var subject_emotions: Dictionary = {}
var emotion_labels: Dictionary = {}

signal emotion_revealed(subject, emotion)
signal subject_calmed(subject)

func _ready():
	# 等待场景加载完成
	await get_tree().process_frame
	_scan_subjects()

func _scan_subjects():
	var subjects = get_tree().get_nodes_in_group("character")
	for s in subjects:
		if not subject_emotions.has(s):
			_assign_emotion(s)

func _assign_emotion(subject):
	var emotions = [EmotionType.ANXIETY, EmotionType.SADNESS, EmotionType.FEAR, EmotionType.ANGER]
	var emotion = emotions[randi() % emotions.size()]
	subject_emotions[subject] = emotion

func reveal_emotions(stage: int):
	# 只在REM期显示情感
	if stage != 3:
		_hide_all_emotion_labels()
		return
	
	_scan_subjects()

	for subject in subject_emotions.keys():
		if is_instance_valid(subject):
			_show_emotion_label(subject)

func _show_emotion_label(subject):
	if emotion_labels.has(subject):
		return
	
	var label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.z_index = 60
	
	var emotion = subject_emotions[subject]
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
		emotion_labels[subject] = label
		_update_label_position(subject)

		emotion_revealed.emit(subject, emotion)

func _hide_all_emotion_labels():
	for subject in emotion_labels.keys():
		if is_instance_valid(emotion_labels[subject]):
			emotion_labels[subject].queue_free()
	emotion_labels.clear()

func _update_label_position(subject):
	if emotion_labels.has(subject) and is_instance_valid(subject):
		var label = emotion_labels[subject]
		label.position = subject.global_position + Vector2(-20, -35)

func _process(_delta):
	# 更新情感标签位置
	if not emotion_labels.is_empty():
		for subject in emotion_labels.keys():
			if is_instance_valid(subject) and is_instance_valid(emotion_labels[subject]):
				_update_label_position(subject)

func calm_enemy(subject) -> bool:
	if not subject_emotions.has(subject):
		return false

	var _emotion = subject_emotions[subject]

	# 移除情感标签
	if emotion_labels.has(subject):
		if is_instance_valid(emotion_labels[subject]):
			emotion_labels[subject].queue_free()
		emotion_labels.erase(subject)

	# 改变状态为平静
	subject_emotions[subject] = EmotionType.CALM

	# 如果对象有相关方法，尝试调用合适的平静行为（兼容旧敌人方法）
	if subject.has_method("reset_to_patrol"):
		subject.reset_to_patrol()
	if subject.has_method("on_calmed"):
		subject.on_calmed()

	# 改变视觉为平静状态
	if subject.has_node("Visual"):
		var visual = subject.get_node("Visual")
		var tween = create_tween()
		tween.tween_property(visual, "color", Color(0.3, 0.8, 0.5, 1), 0.5)

	subject_calmed.emit(subject)
	print("对象被安抚: " + subject.name)
	return true

func get_emotion_text(subject) -> String:
	if not subject_emotions.has(subject):
		return "未知"

	match subject_emotions[subject]:
		EmotionType.ANXIETY: return "焦虑"
		EmotionType.SADNESS: return "悲伤"
		EmotionType.FEAR: return "恐惧"
		EmotionType.ANGER: return "愤怒"
		EmotionType.CALM: return "平静"
		_: return "未知"

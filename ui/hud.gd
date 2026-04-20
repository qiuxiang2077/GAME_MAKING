extends Control

var sleep_manager = null

func _ready():
	# 查找睡眠管理器
	var current_scene = get_tree().current_scene
	sleep_manager = current_scene.get_node("SleepManager")
	if sleep_manager:
		# 连接信号
		sleep_manager.stage_changed.connect(_on_stage_changed)
		sleep_manager.time_updated.connect(_on_time_updated)
		sleep_manager.fear_updated.connect(_on_fear_updated)
		
		# 初始化显示
		_on_stage_changed(sleep_manager.current_stage)
		_on_time_updated(sleep_manager.time_remaining)
		_on_fear_updated(sleep_manager.fear_level)

func _on_stage_changed(stage):
	# 更新睡眠阶段显示
	$SleepStage.text = "睡眠阶段: " + sleep_manager.get_stage_name()

func _on_time_updated(remaining):
	# 更新剩余时间显示
	var minutes = remaining / 60
	var seconds = remaining % 60
	$TimeRemaining.text = "剩余时间: %d:%02d" % [minutes, seconds]

func _on_fear_updated(level):
	# 更新恐惧值显示
	$FearLevel.text = "恐惧值: %d/100" % [level]

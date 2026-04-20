extends Control

var sleep_manager = null
var game_manager = null

func _ready():
	# 查找SleepManager
	await get_tree().process_frame
	
	var root = get_tree().current_scene
	if root:
		sleep_manager = root.get_node_or_null("SleepManager")
		if sleep_manager:
			print("HUD: 找到SleepManager")
			# 连接信号
			sleep_manager.stage_changed.connect(_on_stage_changed)
			sleep_manager.time_updated.connect(_on_time_updated)
			sleep_manager.fear_updated.connect(_on_fear_updated)
			
			# 初始化显示
			_on_stage_changed(sleep_manager.current_stage)
			_on_time_updated(sleep_manager.time_remaining)
			_on_fear_updated(sleep_manager.fear_level)
		else:
			print("HUD: 未找到SleepManager")
	
	# 查找GameManager（自动加载）
	game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		print("HUD: 找到GameManager")
		game_manager.memory_collected.connect(_on_memory_collected)
		game_manager.game_over.connect(_on_game_over)
		game_manager.all_memories_collected.connect(_on_victory)
		_update_memory_display(0)
	else:
		print("HUD: 未找到
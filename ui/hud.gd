extends Control

var sleep_manager = null
var game_manager = null

@onready var restart_button = $RestartButton
@onready var game_over_panel = $GameOverPanel
@onready var victory_panel = $VictoryPanel
@onready var status_panel = $StatusPanel

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
		print("HUD: 未找到GameManager")
	
	# 连接重新开始按钮
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
		restart_button.mouse_entered.connect(_on_restart_hover)
		restart_button.mouse_exited.connect(_on_restart_unhover)
	
	# 连接游戏结束面板的重新开始按钮
	var restart_button2 = game_over_panel.get_node_or_null("RestartButton2")
	if restart_button2:
		restart_button2.pressed.connect(_on_restart_pressed)
	
	# 连接胜利面板的按钮
	var restart_button3 = victory_panel.get_node_or_null("ButtonContainer/RestartButton3")
	var continue_button = victory_panel.get_node_or_null("ButtonContainer/ContinueButton")
	if restart_button3:
		restart_button3.pressed.connect(_on_restart_pressed)
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)

func _process(delta):
	# 每帧更新，确保数据同步
	if sleep_manager:
		_on_time_updated(sleep_manager.time_remaining)
		_on_fear_updated(sleep_manager.fear_level)

func _on_restart_hover():
	# 鼠标悬停时按钮放大效果
	if restart_button:
		var tween = create_tween()
		tween.tween_property(restart_button, "scale", Vector2(1.1, 1.1), 0.2)

func _on_restart_unhover():
	# 按钮恢复效果
	if restart_button:
		var tween = create_tween()
		tween.tween_property(restart_button, "scale", Vector2(1.0, 1.0), 0.2)

func _on_stage_changed(stage):
	# 更新睡眠阶段显示
	if sleep_manager and status_panel:
		var stage_name = sleep_manager.get_stage_name()
		var stage_label = status_panel.get_node_or_null("StageLabel")
		if stage_label:
			stage_label.text = "睡眠阶段: " + stage_name
		print("HUD: 阶段更新为 " + stage_name)

func _on_time_updated(remaining):
	# 更新剩余时间显示
	if status_panel:
		var time_label = status_panel.get_node_or_null("TimeLabel")
		if time_label:
			var minutes = int(remaining) / 60
			var seconds = int(remaining) % 60
			time_label.text = "剩余时间: %d:%02d" % [minutes, seconds]

func _on_fear_updated(level):
	# 更新恐惧值显示
	if status_panel:
		var fear_label = status_panel.get_node_or_null("FearLabel")
		if fear_label:
			fear_label.text = "恐惧值: %d/100" % [int(level)]
			
			# 恐惧值颜色变化
			if level < 30:
				fear_label.modulate = Color(0.7, 0.9, 0.7)  # 绿色
			elif level < 60:
				fear_label.modulate = Color(0.9, 0.9, 0.5)  # 黄色
			else:
				fear_label.modulate = Color(0.9, 0.5, 0.5)  # 红色

func _on_memory_collected(count):
	# 更新记忆碎片显示
	_update_memory_display(count)
	
	# 显示收集动画
	if status_panel:
		var memory_label = status_panel.get_node_or_null("MemoryLabel")
		if memory_label:
			var tween = create_tween()
			memory_label.scale = Vector2(1.5, 1.5)
			tween.tween_property(memory_label, "scale", Vector2(1.0, 1.0), 0.3)

func _update_memory_display(count):
	if status_panel:
		var memory_label = status_panel.get_node_or_null("MemoryLabel")
		if memory_label:
			memory_label.text = "记忆碎片: %d/7" % [count]

func _on_game_over():
	# 显示游戏结束面板
	if game_over_panel:
		game_over_panel.visible = true
		
		# 淡入动画
		game_over_panel.modulate = Color(1, 1, 1, 0)
		var tween = create_tween()
		tween.tween_property(game_over_panel, "modulate", Color(1, 1, 1, 1), 0.5)

func _on_victory():
	# 显示胜利面板
	if victory_panel:
		victory_panel.visible = true
		
		# 淡入动画
		victory_panel.modulate = Color(1, 1, 1, 0)
		var tween = create_tween()
		tween.tween_property(victory_panel, "modulate", Color(1, 1, 1, 1), 0.5)
		
		# 星星动画
		await get_tree().create_timer(0.3).timeout
		_animate_stars()

func _animate_stars():
	# 星星依次出现的动画
	var star_container = victory_panel.get_node_or_null("StarContainer")
	if star_container:
		for i in range(1, 4):
			var star = star_container.get_node_or_null("Star" + str(i))
			if star:
				star.visible = true
				star.scale = Vector2(0, 0)
				var tween = create_tween()
				tween.tween_property(star, "scale", Vector2(1.5, 1.5), 0.3)
				tween.tween_property(star, "scale", Vector2(1.0, 1.0), 0.2)
				await get_tree().create_timer(0.2).timeout

func _on_restart_pressed():
	print("重新开始游戏")
	
	# 按钮点击动画
	if restart_button:
		var tween = create_tween()
		tween.tween_property(restart_button, "scale", Vector2(0.9, 0.9), 0.1)
		tween.tween_property(restart_button, "scale", Vector2(1.0, 1.0), 0.1)
		
		await tween.finished
	
	# 重置游戏
	if game_manager:
		game_manager.reset_game()
	get_tree().reload_current_scene()

func _on_continue_pressed():
	print("继续游戏 - 这里可以进入下一关")
	# 这里可以添加进入下一关的逻辑

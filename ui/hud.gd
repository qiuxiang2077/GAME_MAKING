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
		print("HUD: 未找到GameManager")
	
	# 连接重新开始按钮
	$RestartButton.pressed.connect(_on_restart_pressed)
	$RestartButton.mouse_entered.connect(_on_restart_hover)
	$RestartButton.mouse_exited.connect(_on_restart_unhover)
	
	# 连接游戏结束面板的重新开始按钮
	$GameOverPanel/RestartButton2.pressed.connect(_on_restart_pressed)
	
	# 连接胜利面板的按钮
	$VictoryPanel/RestartButton3.pressed.connect(_on_restart_pressed)
	$VictoryPanel/ContinueButton.pressed.connect(_on_continue_pressed)

func _process(delta):
	# 每帧更新，确保数据同步
	if sleep_manager:
		_on_time_updated(sleep_manager.time_remaining)
		_on_fear_updated(sleep_manager.fear_level)

func _on_restart_hover():
	# 鼠标悬停时按钮放大效果
	var tween = create_tween()
	tween.tween_property($RestartButton, "scale", Vector2(1.1, 1.1), 0.2)

func _on_restart_unhover():
	# 按钮恢复效果
	var tween = create_tween()
	tween.tween_property($RestartButton, "scale", Vector2(1.0, 1.0), 0.2)

func _on_stage_changed(stage):
	# 更新睡眠阶段显示
	if sleep_manager:
		var stage_name = sleep_manager.get_stage_name()
		$StatusPanel/StageLabel.text = "睡眠阶段: " + stage_name
		print("HUD: 阶段更新为 " + stage_name)

func _on_time_updated(remaining):
	# 更新剩余时间显示
	var minutes = int(remaining) / 60
	var seconds = int(remaining) % 60
	$StatusPanel/TimeLabel.text = "剩余时间: %d:%02d" % [minutes, seconds]

func _on_fear_updated(level):
	# 更新恐惧值显示
	$StatusPanel/FearLabel.text = "恐惧值: %d/100" % [int(level)]
	
	# 恐惧值颜色变化
	if level < 30:
		$StatusPanel/FearLabel.modulate = Color(0.7, 0.9, 0.7)  # 绿色
	elif level < 60:
		$StatusPanel/FearLabel.modulate = Color(0.9, 0.9, 0.5)  # 黄色
	else:
		$StatusPanel/FearLabel.modulate = Color(0.9, 0.5, 0.5)  # 红色

func _on_memory_collected(count):
	# 更新记忆碎片显示
	_update_memory_display(count)
	
	# 显示收集动画
	var tween = create_tween()
	$StatusPanel/MemoryLabel.scale = Vector2(1.5, 1.5)
	tween.tween_property($StatusPanel/MemoryLabel, "scale", Vector2(1.0, 1.0), 0.3)

func _update_memory_display(count):
	$StatusPanel/MemoryLabel.text = "记忆碎片: %d/7" % [count]

func _on_game_over():
	# 显示游戏结束面板
	$GameOverPanel.visible = true
	
	# 淡入动画
	$GameOverPanel.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property($GameOverPanel, "modulate", Color(1, 1, 1, 1), 0.5)

func _on_victory():
	# 显示胜利面板
	$VictoryPanel.visible = true
	
	# 淡入动画
	$VictoryPanel.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property($VictoryPanel, "modulate", Color(1, 1, 1, 1), 0.5)
	
	# 星星动画
	await get_tree().create_timer(0.3).timeout
	_animate_stars()

func _animate_stars():
	# 星星依次出现的动画
	for i in range(1, 4):
		var star = $VictoryPanel/StarContainer.get_node_or_null("Star" + str(i))
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
	var tween = create_tween()
	tween.tween_property($RestartButton, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property($RestartButton, "scale", Vector2(1.0, 1.0), 0.1)
	
	await tween.finished
	
	# 重置游戏
	if game_manager:
		game_manager.reset_game()
	get_tree().reload_current_scene()

func _on_continue_pressed():
	print("继续游戏 - 这里可以进入下一关")
	# 这里可以添加进入下一关的逻辑

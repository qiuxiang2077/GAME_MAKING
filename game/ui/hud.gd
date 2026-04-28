extends Control

var sleep_manager = null
var game_manager = null

@onready var restart_button = $RestartButton
@onready var game_over_panel = $GameOverPanel
@onready var victory_panel = $VictoryPanel
@onready var status_panel = $StatusPanel
@onready var stage_advance_panel = $StageAdvancePanel

# Farming UI elements
@onready var story_progress_label = $StatusPanel/StoryProgressLabel
@onready var mood_label = $StatusPanel/MoodLabel
@onready var chapter_label = $StatusPanel/ChapterLabel

# Optional UI nodes (may be absent after refactor)
var gold_label = null
var energy_label = null
var time_label = null
var season_label = null
var inventory_panel = null

var advance_panel_visible = false

func _ready():
	await get_tree().process_frame
	
	var root = get_tree().current_scene
	if root:
		sleep_manager = root.get_node_or_null("SleepManager")
		if sleep_manager:
			sleep_manager.stage_changed.connect(_on_stage_changed)
			sleep_manager.fear_updated.connect(_on_fear_updated)
			sleep_manager.cycle_completed.connect(_on_cycle_completed)
			sleep_manager.objective_updated.connect(_on_objective_updated)
			sleep_manager.objective_completed.connect(_on_objective_completed)
			sleep_manager.stage_advance_available.connect(_on_stage_advance_available)
			_on_stage_changed(sleep_manager.current_stage)
			_on_fear_updated(sleep_manager.fear_level)
			_on_objective_updated(0, sleep_manager.stage_fragments_required)
	
	# Resolve GameManager robustly
	game_manager = get_node_or_null("/root/GameManager")
	if not game_manager:
		var scene_root = get_tree().current_scene
		if scene_root and scene_root.has_node("GameManager"):
			game_manager = scene_root.get_node("GameManager")

	if game_manager:
		if game_manager.has_signal("memory_collected"):
			game_manager.memory_collected.connect(_on_memory_collected)
		if game_manager.has_signal("story_progressed"):
			game_manager.story_progressed.connect(_on_story_progressed)
		if game_manager.has_signal("mood_changed"):
			game_manager.mood_changed.connect(_on_mood_changed)
		_update_memory_display(0)
		_update_story_progress(0.0)
		_update_mood("contemplative")

		# Connect narrative signals if available as a child node
		if game_manager.has_node("NarrativeSystem"):
			var narrative = game_manager.get_node("NarrativeSystem")
			if narrative and narrative.has_signal("chapter_changed"):
				narrative.chapter_changed.connect(_on_chapter_changed)
				_on_chapter_changed(1)

		# Populate optional UI node references safely
		gold_label = status_panel.get_node_or_null("GoldLabel") if status_panel else null
		energy_label = status_panel.get_node_or_null("EnergyLabel") if status_panel else null
		time_label = status_panel.get_node_or_null("TimeLabel") if status_panel else null
		season_label = status_panel.get_node_or_null("SeasonLabel") if status_panel else null
		inventory_panel = get_node_or_null("InventoryPanel")
	
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	
	var restart_button2 = game_over_panel.get_node_or_null("RestartButton2")
	if restart_button2:
		restart_button2.pressed.connect(_on_restart_pressed)
	
	var restart_button3 = victory_panel.get_node_or_null("ButtonContainer/RestartButton3")
	var continue_button = victory_panel.get_node_or_null("ButtonContainer/ContinueButton")
	if restart_button3:
		restart_button3.pressed.connect(_on_restart_pressed)
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
	
	var later_button = stage_advance_panel.get_node_or_null("LaterButton")
	if later_button:
		later_button.pressed.connect(_hide_advance_panel)

func _process(_delta):
	if sleep_manager:
		_on_fear_updated(sleep_manager.fear_level)
	
	if advance_panel_visible and Input.is_action_just_pressed("interact"):
		_advance_stage()

func _on_stage_changed(stage):
	if sleep_manager and status_panel:
		var stage_name = sleep_manager.get_stage_name()
		var stage_label = status_panel.get_node_or_null("StageLabel")
		if stage_label:
			stage_label.text = stage_name
			
			match stage:
				0: stage_label.add_theme_color_override("font_color", Color(0.7, 0.8, 1, 1))
				1: stage_label.add_theme_color_override("font_color", Color(0.5, 0.7, 1, 1))
				2: stage_label.add_theme_color_override("font_color", Color(0.6, 0.3, 0.8, 1))
				3: stage_label.add_theme_color_override("font_color", Color(1, 0.6, 0.8, 1))

func _on_cycle_completed(_cycle_num):
	if status_panel:
		var cycle_label = status_panel.get_node_or_null("CycleLabel")
		if cycle_label and sleep_manager:
			cycle_label.text = "周期 %d/%d" % [sleep_manager.current_cycle, sleep_manager.max_cycles]

func _on_objective_updated(current, required):
	if status_panel:
		var objective_label = status_panel.get_node_or_null("ObjectivePanel/ObjectiveLabel")
		if objective_label and sleep_manager:
			objective_label.text = sleep_manager.get_stage_objective_text()
			
			if current >= required and required > 0:
				objective_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3, 1))
			else:
				objective_label.add_theme_color_override("font_color", Color(0.7, 0.9, 0.7, 1))

func _on_objective_completed():
	if status_panel:
		var objective_label = status_panel.get_node_or_null("ObjectivePanel/ObjectiveLabel")
		if objective_label:
			var tween = create_tween()
			objective_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3, 1))
			tween.tween_property(objective_label, "scale", Vector2(1.1, 1.1), 0.15)
			tween.tween_property(objective_label, "scale", Vector2(1.0, 1.0), 0.15)

func _on_stage_advance_available():
	_show_advance_panel()

func _show_advance_panel():
	if stage_advance_panel:
		stage_advance_panel.visible = true
		stage_advance_panel.modulate = Color(1, 1, 1, 0)
		stage_advance_panel.scale = Vector2(0.9, 0.9)
		
		var tween = create_tween()
		tween.tween_property(stage_advance_panel, "modulate", Color(1, 1, 1, 1), 0.4)
		tween.parallel().tween_property(stage_advance_panel, "scale", Vector2(1.0, 1.0), 0.4).set_ease(Tween.EASE_OUT)
		
		advance_panel_visible = true

func _hide_advance_panel():
	if stage_advance_panel:
		var tween = create_tween()
		tween.tween_property(stage_advance_panel, "modulate", Color(1, 1, 1, 0), 0.3)
		tween.parallel().tween_property(stage_advance_panel, "scale", Vector2(0.9, 0.9), 0.3)
		tween.tween_callback(func(): stage_advance_panel.visible = false)
		
		advance_panel_visible = false

func _advance_stage():
	if sleep_manager:
		if sleep_manager.try_advance_stage():
			_hide_advance_panel()

func _on_fear_updated(level):
	if status_panel:
		var fear_label = status_panel.get_node_or_null("FearLabel")
		var fear_bar = status_panel.get_node_or_null("FearBarBg")
		
		if fear_label:
			fear_label.text = "恐惧: %d" % [int(level)]
			
			if level < 30:
				fear_label.add_theme_color_override("font_color", Color(0.5, 0.7, 0.5, 1))
			elif level < 60:
				fear_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.3, 1))
			elif level < 80:
				fear_label.add_theme_color_override("font_color", Color(0.9, 0.4, 0.3, 1))
			else:
				fear_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2, 1))
		
		if fear_bar:
			fear_bar.value = level

func _on_memory_collected(count):
	_update_memory_display(count)
	
	if status_panel:
		var memory_label = status_panel.get_node_or_null("MemoryLabel")
		if memory_label:
			var tween = create_tween()
			memory_label.scale = Vector2(1.4, 1.4)
			tween.tween_property(memory_label, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT)
	
	if sleep_manager:
		sleep_manager.on_fragment_collected()

func _update_memory_display(count):
	if status_panel:
		var memory_label = status_panel.get_node_or_null("MemoryLabel")
		if memory_label:
			memory_label.text = "记忆碎片: %d/7" % [count]

func _on_game_over():
	if game_over_panel:
		game_over_panel.visible = true
		game_over_panel.modulate = Color(1, 1, 1, 0)
		var tween = create_tween()
		tween.tween_property(game_over_panel, "modulate", Color(1, 1, 1, 1), 0.5)

func _on_victory():
	if victory_panel:
		victory_panel.visible = true
		victory_panel.modulate = Color(1, 1, 1, 0)
		var tween = create_tween()
		tween.tween_property(victory_panel, "modulate", Color(1, 1, 1, 1), 0.5)
		
		await get_tree().create_timer(0.3).timeout
		_animate_stars()
		await get_tree().create_timer(2.0).timeout  # 给玩家时间欣赏胜利画面
		_on_continue_pressed()

func _animate_stars():
	var star_container = victory_panel.get_node_or_null("StarContainer")
	if star_container:
		for i in range(1, 4):
			var star = star_container.get_node_or_null("Star" + str(i))
			if star:
				star.visible = true
				star.scale = Vector2(0, 0)
				var tween = create_tween()
				tween.tween_property(star, "scale", Vector2(1.5, 1.5), 0.25).set_ease(Tween.EASE_OUT)
				tween.tween_property(star, "scale", Vector2(1.0, 1.0), 0.15).set_ease(Tween.EASE_IN)
				await get_tree().create_timer(0.15).timeout

func _on_restart_pressed():
	if restart_button:
		var tween = create_tween()
		tween.tween_property(restart_button, "scale", Vector2(0.9, 0.9), 0.08)
		tween.tween_property(restart_button, "scale", Vector2(1.0, 1.0), 0.08)
	
	if game_manager and game_manager.has_method("reset_game"):
		game_manager.reset_game()
	get_tree().reload_current_scene()

func _on_continue_pressed():
	# In narrative mode, continue simply reloads or advances scene as appropriate
	get_tree().reload_current_scene()

func _on_gold_changed(amount: int):
	_update_gold_display(amount)

func _on_energy_changed(amount: int):
	_update_energy_display(amount)

func _on_time_updated(_current_time: int, _is_daytime: bool):
	if time_label and game_manager and game_manager.time_system:
		time_label.text = "Time: " + game_manager.time_system.get_time_string()

func _on_season_changed(season: String):
	if season_label:
		season_label.text = "Season: " + season.capitalize()

func _on_inventory_updated(inventory: Dictionary):
	_update_inventory_display(inventory)

func _on_story_progressed(progress: float):
	_update_story_progress(progress)

func _on_mood_changed(new_mood: String):
	_update_mood(new_mood)

func _on_chapter_changed(chapter: int):
	if chapter_label:
		chapter_label.text = "Chapter: " + str(chapter)

func _update_gold_display(amount: int):
	if gold_label:
		gold_label.text = "Gold: " + str(amount)

func _update_energy_display(amount: int):
	if energy_label:
		energy_label.text = "Energy: " + str(amount) + "/100"

func _update_inventory_display(inventory: Dictionary):
	if inventory_panel:
		# Update inventory UI - this would need actual UI elements
		print("Inventory updated: " + str(inventory))

func _update_story_progress(progress: float):
	if story_progress_label:
		story_progress_label.text = "Story Progress: " + str(int(progress * 100)) + "%"

func _update_mood(mood: String):
	if mood_label:
		mood_label.text = "Mood: " + mood.capitalize()

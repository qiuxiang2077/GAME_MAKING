extends Node

enum SleepStage {
	AWAKE,
	LIGHT_SLEEP,
	DEEP_SLEEP,
	REM
}

var current_stage = SleepStage.AWAKE
var current_cycle = 1
var max_cycles = 5

var fear_level = 0
var max_fear_level = 100

var emotional_energy = 0
var max_emotional_energy = 100

var stage_objective_completed = false
var can_advance_stage = false

var stage_fragments_collected = 0
var stage_fragments_required = 2

var timer = null

# 子系统引用
var light_sleep_effects = null
var vision_system = null
var emotion_system = null

signal stage_changed(new_stage)
signal objective_updated(current, required)
signal objective_completed()
signal stage_advance_available()
signal stage_advanced(new_stage)
signal fear_updated(level)
signal emotional_energy_updated(energy)
signal fear_panic_triggered()
signal cycle_completed(cycle_num)
signal all_cycles_completed()

func _ready():
	_setup_timers()
	_setup_subsystems()
	_update_stage_objective()

func _setup_timers():
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func _setup_subsystems():
	# 浅睡期效果系统
	light_sleep_effects = LightSleepEffects.new()
	add_child(light_sleep_effects)
	
	# 视野系统
	vision_system = VisionSystem.new()
	add_child(vision_system)
	
	# 情感系统
	emotion_system = EmotionSystem.new()
	add_child(emotion_system)

func _on_timer_timeout():
	if current_stage == SleepStage.DEEP_SLEEP:
		fear_level += 0.8
		if fear_level > max_fear_level:
			fear_level = max_fear_level
		fear_updated.emit(fear_level)

		if fear_level >= 80 and not stage_objective_completed:
			fear_panic_triggered.emit()
		
		# 更新视野系统
		var player = get_tree().get_first_node_in_group("player")
		if player and vision_system:
			vision_system.update_vision(player.global_position, fear_level, current_stage)

	elif current_stage == SleepStage.REM:
		emotional_energy += 0.5
		if emotional_energy > max_emotional_energy:
			emotional_energy = max_emotional_energy
		emotional_energy_updated.emit(emotional_energy)
		
		# 显示敌人情感
		if emotion_system:
			emotion_system.reveal_emotions(current_stage)
	
	elif current_stage == SleepStage.LIGHT_SLEEP:
		# 浅睡期状态波动已在子系统中处理
		pass
	
	else:
		# 其他阶段关闭特殊效果
		if vision_system:
			vision_system.set_full_vision()
		if emotion_system:
			emotion_system.reveal_emotions(current_stage)

func _update_stage_objective():
	stage_objective_completed = false
	can_advance_stage = false
	stage_fragments_collected = 0

	match current_stage:
		SleepStage.AWAKE:
			stage_fragments_required = 0
			stage_objective_completed = true
			can_advance_stage = true
			stage_advance_available.emit()
			_stop_stage_effects()
		SleepStage.LIGHT_SLEEP:
			stage_fragments_required = 2
			_start_light_sleep_effects()
		SleepStage.DEEP_SLEEP:
			stage_fragments_required = 1
			fear_level = 0
			_start_deep_sleep_effects()
		SleepStage.REM:
			stage_fragments_required = 1
			emotional_energy = 0
			_start_rem_effects()

	objective_updated.emit(stage_fragments_collected, stage_fragments_required)

func _start_light_sleep_effects():
	if light_sleep_effects:
		light_sleep_effects.start_fluctuation()
	if vision_system:
		vision_system.set_full_vision()

func _start_deep_sleep_effects():
	if light_sleep_effects:
		light_sleep_effects.stop_fluctuation()
	# 视野系统会在 _on_timer_timeout 中自动更新

func _start_rem_effects():
	if light_sleep_effects:
		light_sleep_effects.stop_fluctuation()
	if vision_system:
		vision_system.set_full_vision()
	if emotion_system:
		emotion_system.reveal_emotions(current_stage)

func _stop_stage_effects():
	if light_sleep_effects:
		light_sleep_effects.stop_fluctuation()
	if vision_system:
		vision_system.set_full_vision()
	if emotion_system:
		emotion_system.reveal_emotions(current_stage)

func on_fragment_collected():
	if current_stage == SleepStage.LIGHT_SLEEP or current_stage == SleepStage.REM:
		stage_fragments_collected += 1
		objective_updated.emit(stage_fragments_collected, stage_fragments_required)

		if stage_fragments_collected >= stage_fragments_required and not stage_objective_completed:
			_complete_objective()

func on_door_found():
	if current_stage == SleepStage.DEEP_SLEEP and not stage_objective_completed:
		_complete_objective()

func _complete_objective():
	stage_objective_completed = true
	can_advance_stage = true
	objective_completed.emit()
	stage_advance_available.emit()
	print("阶段目标达成！按空格进入下一阶段")

func try_advance_stage() -> bool:
	if not can_advance_stage:
		return false

	if current_stage == SleepStage.REM:
		current_cycle += 1
		cycle_completed.emit(current_cycle - 1)

		if current_cycle > max_cycles:
			all_cycles_completed.emit()
			print("所有睡眠周期完成！")
			return true

		_update_stage(SleepStage.AWAKE)
		print("开始第 " + str(current_cycle) + " 个睡眠周期")
	else:
		_update_stage(current_stage + 1)

	stage_advanced.emit(current_stage)
	return true

func _update_stage(new_stage):
	current_stage = new_stage

	if current_stage != SleepStage.DEEP_SLEEP:
		fear_level = 0
		fear_updated.emit(fear_level)

	if current_stage != SleepStage.REM:
		emotional_energy = 0
		emotional_energy_updated.emit(emotional_energy)

	stage_changed.emit(current_stage)
	_update_stage_objective()
	print("睡眠阶段切换到: " + get_stage_name())

func get_stage_name():
	match current_stage:
		SleepStage.AWAKE:
			return "清醒期"
		SleepStage.LIGHT_SLEEP:
			return "浅睡期"
		SleepStage.DEEP_SLEEP:
			return "深睡期"
		SleepStage.REM:
			return "REM期"
		_:
			return "未知"

func get_stage_objective_text():
	match current_stage:
		SleepStage.AWAKE:
			return "找到梦境入口"
		SleepStage.LIGHT_SLEEP:
			return "收集记忆碎片 (%d/%d)" % [stage_fragments_collected, stage_fragments_required]
		SleepStage.DEEP_SLEEP:
			return "找到REM之门"
		SleepStage.REM:
			return "完成剧情挑战"
		_:
			return ""

func get_fear_speed_multiplier():
	if current_stage != SleepStage.DEEP_SLEEP:
		return 1.0

	if fear_level < 30:
		return 1.0
	elif fear_level < 60:
		return 0.9
	elif fear_level < 80:
		return 0.85
	else:
		return 0.5

func is_panic_state():
	return current_stage == SleepStage.DEEP_SLEEP and fear_level >= 80

func reduce_fear(amount):
	fear_level = max(0, fear_level - amount)
	fear_updated.emit(fear_level)

func add_emotional_energy(amount):
	if current_stage == SleepStage.REM:
		emotional_energy = min(max_emotional_energy, emotional_energy + amount)
		emotional_energy_updated.emit(emotional_energy)

func use_emotional_energy(amount):
	if current_stage == SleepStage.REM and emotional_energy >= amount:
		emotional_energy -= amount
		emotional_energy_updated.emit(emotional_energy)
		return true
	return false

func set_stage(stage):
	if stage >= 0 and stage < 4:
		_update_stage(stage)

func get_fear_effect():
	if current_stage != SleepStage.DEEP_SLEEP:
		return 0

	if fear_level < 30:
		return 0
	elif fear_level < 60:
		return 1
	elif fear_level < 80:
		return 2
	else:
		return 3

func get_cycle_info():
	return "周期 %d/%d" % [current_cycle, max_cycles]

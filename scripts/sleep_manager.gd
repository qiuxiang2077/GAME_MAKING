extends Node

enum SleepStage {
	AWAKE,      # 清醒期
	LIGHT_SLEEP, # 浅睡期
	DEEP_SLEEP,  # 深睡期
	REM         # REM期
}

var current_stage = SleepStage.AWAKE
var current_cycle = 1
var max_cycles = 5

var stage_durations = {
	SleepStage.AWAKE: 300,
	SleepStage.LIGHT_SLEEP: 600,
	SleepStage.DEEP_SLEEP: 600,
	SleepStage.REM: 900
}

var time_remaining = stage_durations[current_stage]

var fear_level = 0
var max_fear_level = 100

var emotional_energy = 0
var max_emotional_energy = 100

signal stage_changed(new_stage)
signal time_updated(remaining)
signal fear_updated(level)
signal emotional_energy_updated(energy)
signal fear_panic_triggered()
signal cycle_completed(cycle_num)
signal all_cycles_completed()

var timer = null
var is_cycle_active = true

func _ready():
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	_update_stage(current_stage)

func _on_timer_timeout():
	if not is_cycle_active:
		return
	
	if time_remaining > 0:
		time_remaining -= 1
		time_updated.emit(time_remaining)
		
		if current_stage == SleepStage.DEEP_SLEEP:
			fear_level += 0.5
			if fear_level > max_fear_level:
				fear_level = max_fear_level
			fear_updated.emit(fear_level)
			
			if fear_level >= 80:
				fear_panic_triggered.emit()
		
		elif current_stage == SleepStage.REM:
			emotional_energy += 0.3
			if emotional_energy > max_emotional_energy:
				emotional_energy = max_emotional_energy
			emotional_energy_updated.emit(emotional_energy)
	else:
		_next_stage()

func _next_stage():
	if current_stage == SleepStage.REM:
		# REM期结束 = 一个完整周期结束
		current_cycle += 1
		cycle_completed.emit(current_cycle - 1)
		
		if current_cycle > max_cycles:
			# 所有周期完成
			is_cycle_active = false
			all_cycles_completed.emit()
			print("所有睡眠周期完成！")
			return
		
		# 开始新周期：回到清醒期
		_update_stage(SleepStage.AWAKE)
		print("开始第 " + str(current_cycle) + " 个睡眠周期")
	else:
		# 进入下一阶段
		_update_stage(current_stage + 1)

func _update_stage(new_stage):
	current_stage = new_stage
	time_remaining = stage_durations[current_stage]
	
	if current_stage != SleepStage.DEEP_SLEEP:
		fear_level = 0
		fear_updated.emit(fear_level)
	
	if current_stage != SleepStage.REM:
		emotional_energy = 0
		emotional_energy_updated.emit(emotional_energy)
	
	stage_changed.emit(current_stage)
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

func get_fear_speed_multiplier():
	# 设计文档: 61-80中度恐慌移动速度-15%, 81-100重度恐慌无法控制
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
	# 重度恐慌：无法控制角色
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

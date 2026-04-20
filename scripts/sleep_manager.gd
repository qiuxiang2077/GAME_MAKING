extends Node

# 睡眠阶段枚举
enum SleepStage {
	AWAKE,      # 清醒期
	LIGHT_SLEEP, # 浅睡期
	DEEP_SLEEP,  # 深睡期
	REM         # REM期
}

# 当前睡眠阶段
var current_stage = SleepStage.AWAKE
# 阶段持续时间（秒）
var stage_durations = {
	SleepStage.AWAKE: 300,      # 5分钟
	SleepStage.LIGHT_SLEEP: 600, # 10分钟
	SleepStage.DEEP_SLEEP: 600,  # 10分钟
	SleepStage.REM: 900          # 15分钟
}
# 阶段剩余时间
var time_remaining = stage_durations[current_stage]

# 恐惧值（深睡期使用）
var fear_level = 0
var max_fear_level = 100

# 情绪能量（REM期使用）
var emotional_energy = 0
var max_emotional_energy = 100

# 信号
signal stage_changed(new_stage)
signal time_updated(remaining)
signal fear_updated(level)
signal emotional_energy_updated(energy)
signal fear_panic_triggered()

var timer = null

func _ready():
	# 创建计时器
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	# 初始化
	_update_stage(current_stage)

func _on_timer_timeout():
	if time_remaining > 0:
		time_remaining -= 1
		time_updated.emit(time_remaining)
		
		# 深睡期恐惧值增长
		if current_stage == SleepStage.DEEP_SLEEP:
			fear_level += 0.5
			if fear_level > max_fear_level:
				fear_level = max_fear_level
			fear_updated.emit(fear_level)
			
			# 检查是否触发恐慌
			if fear_level >= 80:
				fear_panic_triggered.emit()
		
		# REM期情绪能量自然恢复
		elif current_stage == SleepStage.REM:
			emotional_energy += 0.3
			if emotional_energy > max_emotional_energy:
				emotional_energy = max_emotional_energy
			emotional_energy_updated.emit(emotional_energy)
	else:
		# 切换到下一个阶段
		_next_stage()

func _next_stage():
	var next_stage = (current_stage + 1) % 4
	_update_stage(next_stage)

func _update_stage(new_stage):
	current_stage = new_stage
	time_remaining = stage_durations[current_stage]
	
	# 重置恐惧值
	if current_stage != SleepStage.DEEP_SLEEP:
		fear_level = 0
		fear_updated.emit(fear_level)
	
	# 重置情绪能量
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

func reduce_fear(amount):
	"""减少恐惧值"""
	fear_level = max(0, fear_level - amount)
	fear_updated.emit(fear_level)

func add_emotional_energy(amount):
	"""增加情绪能量"""
	if current_stage == SleepStage.REM:
		emotional_energy = min(max_emotional_energy, emotional_energy + amount)
		emotional_energy_updated.emit(emotional_energy)

func use_emotional_energy(amount):
	"""使用情绪能量"""
	if current_stage == SleepStage.REM and emotional_energy >= amount:
		emotional_energy -= amount
		emotional_energy_updated.emit(emotional_energy)
		return true
	return false

func set_stage(stage):
	"""手动设置睡眠阶段"""
	if stage >= 0 and stage < 4:
		_update_stage(stage)

func get_fear_effect():
	"""获取恐惧效果"""
	if current_stage != SleepStage.DEEP_SLEEP:
		return 0
	
	if fear_level < 30:
		return 0  # 正常状态
	elif fear_level < 60:
		return 1  # 轻微恐慌
	elif fear_level < 80:
		return 2  # 中度恐慌
	else:
		return 3  # 重度恐慌

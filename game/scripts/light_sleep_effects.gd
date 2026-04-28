class_name LightSleepEffects
extends Node

@export var fluctuation_interval: float = 8.0
@export var speed_variation: float = 0.2
@export var perception_variation: float = 0.2

var fluctuation_timer: Timer = null
var current_speed_multiplier: float = 1.0
var current_perception_multiplier: float = 1.0

signal speed_fluctuated(multiplier)
signal perception_fluctuated(multiplier)
signal hallucination_triggered()

func _ready():
	fluctuation_timer = Timer.new()
	fluctuation_timer.wait_time = fluctuation_interval
	fluctuation_timer.autostart = false
	fluctuation_timer.timeout.connect(_on_fluctuation)
	add_child(fluctuation_timer)

func start_fluctuation():
	fluctuation_timer.start()
	_on_fluctuation()

func stop_fluctuation():
	fluctuation_timer.stop()
	current_speed_multiplier = 1.0
	current_perception_multiplier = 1.0
	speed_fluctuated.emit(1.0)
	perception_fluctuated.emit(1.0)

func _on_fluctuation():
	# 随机波动 ±20%
	current_speed_multiplier = 1.0 + randf_range(-speed_variation, speed_variation)
	current_perception_multiplier = 1.0 + randf_range(-perception_variation, perception_variation)
	
	speed_fluctuated.emit(current_speed_multiplier)
	perception_fluctuated.emit(current_perception_multiplier)
	
	# 10%概率触发幻觉
	if randf() < 0.1:
		hallucination_triggered.emit()
		_trigger_hallucination()

func _trigger_hallucination():
	# 创建临时假敌人
	var fake_enemy = ColorRect.new()
	fake_enemy.color = Color(0.5, 0.1, 0.1, 0.6)
	fake_enemy.size = Vector2(30, 30)
	fake_enemy.position = _get_random_position_near_player()
	fake_enemy.z_index = 5
	
	var root = get_tree().current_scene
	if root:
		root.add_child(fake_enemy)
		
		# 2秒后消失
		var tween = create_tween()
		tween.tween_property(fake_enemy, "modulate:a", 0.0, 2.0)
		tween.tween_callback(func():
			if is_instance_valid(fake_enemy):
				fake_enemy.queue_free()
		)

func _get_random_position_near_player() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var angle = randf() * PI * 2
		var distance = randf_range(150, 300)
		return player.global_position + Vector2(cos(angle), sin(angle)) * distance
	return Vector2.ZERO

func get_speed_multiplier() -> float:
	return current_speed_multiplier

func get_perception_multiplier() -> float:
	return current_perception_multiplier

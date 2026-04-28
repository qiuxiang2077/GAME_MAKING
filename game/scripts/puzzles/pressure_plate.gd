class_name PressurePlate
extends Area2D

signal activated(plate_id)
signal deactivated(plate_id)

@export var plate_id: String = ""
@export var target_door_id: String = ""
@export var stay_active: bool = false
@export var activation_delay: float = 0.0
@export var deactivation_delay: float = 0.0
@export var required_weight: int = 1

var is_active: bool = false
var objects_on_plate: Array = []
var activation_timer: Timer = null
var deactivation_timer: Timer = null

@onready var visual = $Visual
@onready var collision_shape = $CollisionShape2D

func _ready():
	# 连接信号
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# 创建计时器
	if activation_delay > 0:
		activation_timer = Timer.new()
		activation_timer.wait_time = activation_delay
		activation_timer.one_shot = true
		activation_timer.timeout.connect(_activate)
		add_child(activation_timer)
	
	if deactivation_delay > 0:
		deactivation_timer = Timer.new()
		deactivation_timer.wait_time = deactivation_delay
		deactivation_timer.one_shot = true
		deactivation_timer.timeout.connect(_deactivate)
		add_child(deactivation_timer)
	
	# 初始化视觉
	_update_visual()

func _on_body_entered(body):
	# 检查是否是玩家或箱子
	if body.is_in_group("player") or body.is_in_group("pushable"):
		var weight = _get_object_weight(body)
		if weight >= required_weight:
			objects_on_plate.append(body)
			_check_activation()

func _on_body_exited(body):
	if body in objects_on_plate:
		objects_on_plate.erase(body)
		if not stay_active:
			_check_deactivation()

func _get_object_weight(body) -> int:
	if body.is_in_group("player"):
		return 2  # 玩家重量为2
	elif body.has_method("get_weight"):
		return body.get_weight()
	return 1

func _check_activation():
	if objects_on_plate.size() > 0 and not is_active:
		if activation_timer:
			activation_timer.start()
		else:
			_activate()

func _check_deactivation():
	if objects_on_plate.size() == 0 and is_active:
		if deactivation_timer:
			deactivation_timer.start()
		else:
			_deactivate()

func _activate():
	if is_active:
		return
	
	is_active = true
	print("踏板激活: " + plate_id)
	
	# 视觉反馈
	_animate_activation()
	
	# 发送信号
	activated.emit(plate_id)
	
	# 通知目标门
	_notify_target_door(true)

func _deactivate():
	if not is_active:
		return
	
	is_active = false
	print("踏板失活: " + plate_id)
	
	# 视觉反馈
	_animate_deactivation()
	
	# 发送信号
	deactivated.emit(plate_id)
	
	# 通知目标门
	_notify_target_door(false)

func _animate_activation():
	if visual:
		var tween = create_tween()
		tween.tween_property(visual, "color", Color(0.2, 0.8, 0.3, 1.0), 0.2)
		tween.parallel().tween_property(visual, "scale", Vector2(1.1, 1.1), 0.1)
		tween.tween_property(visual, "scale", Vector2(1.0, 1.0), 0.1)

func _animate_deactivation():
	if visual:
		var tween = create_tween()
		tween.tween_property(visual, "color", Color(0.3, 0.3, 0.35, 1.0), 0.3)

func _update_visual():
	if visual:
		if is_active:
			visual.color = Color(0.2, 0.8, 0.3, 1.0)  # 绿色表示激活
		else:
			visual.color = Color(0.3, 0.3, 0.35, 1.0)  # 灰色表示未激活

func _notify_target_door(active: bool):
	if target_door_id.is_empty():
		return
	
	# 查找场景中的门
	var root = get_tree().current_scene
	if root:
		var door = root.find_child(target_door_id, true, false)
		if door and door.has_method("set_open"):
			door.set_open(active)

func reset_plate():
	is_active = false
	objects_on_plate.clear()
	if activation_timer:
		activation_timer.stop()
	if deactivation_timer:
		deactivation_timer.stop()
	_update_visual()

class_name ToggleSwitch
extends Area2D

signal switched_on(switch_id)
signal switched_off(switch_id)

@export var switch_id: String = ""
@export var target_door_ids: Array[String] = []
@export var is_on: bool = false
@export var toggleable: bool = true  # 是否可以多次切换
@export var requires_interaction: bool = true  # 是否需要按互动键

var can_interact: bool = false
var player_in_range: Node2D = null

@onready var visual = $Visual

func _ready():
	# 连接信号
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# 初始化视觉
	_update_visual()

func _process(delta):
	# 检查互动输入
	if can_interact and player_in_range and requires_interaction:
		if Input.is_action_just_pressed("interact"):
			toggle()

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = body
		can_interact = true
		
		# 高亮显示
		highlight(true)
		
		# 如果不需要互动键，立即触发
		if not requires_interaction:
			toggle()

func _on_body_exited(body):
	if body == player_in_range:
		player_in_range = null
		can_interact = false
		
		# 取消高亮
		highlight(false)

func toggle():
	if is_on and not toggleable:
		return
	
	is_on = not is_on
	
	if is_on:
		_switched_on()
	else:
		_switched_off()

func set_switch(state: bool):
	if is_on == state:
		return
	
	is_on = state
	
	if is_on:
		_switched_on()
	else:
		_switched_off()

func _switched_on():
	print("开关打开: " + switch_id)
	
	# 视觉反馈
	_animate_switch_on()
	
	# 发送信号
	switched_on.emit(switch_id)
	
	# 通知目标门
	_notify_doors(true)

func _switched_off():
	print("开关关闭: " + switch_id)
	
	# 视觉反馈
	_animate_switch_off()
	
	# 发送信号
	switched_off.emit(switch_id)
	
	# 通知目标门
	_notify_doors(false)

func _animate_switch_on():
	if visual:
		var tween = create_tween()
		tween.tween_property(visual, "color", Color(0.2, 0.8, 0.3, 1.0), 0.2)
		tween.parallel().tween_property(visual, "position:y", 5.0, 0.1)

func _animate_switch_off():
	if visual:
		var tween = create_tween()
		tween.tween_property(visual, "color", Color(0.8, 0.2, 0.2, 1.0), 0.2)
		tween.parallel().tween_property(visual, "position:y", 0.0, 0.1)

func _update_visual():
	if visual:
		if is_on:
			visual.color = Color(0.2, 0.8, 0.3, 1.0)
			visual.position.y = 5.0
		else:
			visual.color = Color(0.8, 0.2, 0.2, 1.0)
			visual.position.y = 0.0

func highlight(enabled: bool):
	if visual:
		if enabled:
			# 添加发光效果
			visual.modulate = Color(1.2, 1.2, 1.2, 1.0)
		else:
			visual.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _notify_doors(open: bool):
	var root = get_tree().current_scene
	if not root:
		return
	
	for door_id in target_door_ids:
		var door = root.find_child(door_id, true, false)
		if door and door.has_method("set_open"):
			door.set_open(open)

func reset_switch():
	is_on = false
	_update_visual()

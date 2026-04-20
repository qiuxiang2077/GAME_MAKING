class_name SwitchDoor
extends StaticBody2D

enum DoorType {
	SLIDING,      # 滑动门
	ROTATING,     # 旋转门
	DISAPPEARING, # 消失门
	LOCKED        # 需要钥匙的门
}

@export var door_id: String = ""
@export var door_type: DoorType = DoorType.SLIDING
@export var is_open: bool = false
@export var open_direction: Vector2 = Vector2(0, -1)
@export var open_distance: float = 64.0
@export var animation_speed: float = 0.3
@export var is_locked: bool = false

var original_position: Vector2
var is_animating: bool = false

@onready var visual = $Visual
@onready var collision_shape = $CollisionShape2D

func _ready():
	original_position = position
	_update_door_state()

func open():
	if is_open or is_locked or is_animating:
		return
	
	is_open = true
	print("门打开: " + door_id)
	_animate_open()

func close():
	if not is_open or is_animating:
		return
	
	is_open = false
	print("门关闭: " + door_id)
	_animate_close()

func toggle():
	if is_open:
		close()
	else:
		open()

func set_open(open_state: bool):
	if open_state:
		open()
	else:
		close()

func lock():
	is_locked = true
	if visual:
		# 锁定视觉反馈 - 变红
		var tween = create_tween()
		tween.tween_property(visual, "color", Color(0.8, 0.2, 0.2, 1.0), 0.2)

func unlock():
	is_locked = false
	if visual:
		# 解锁视觉反馈 - 恢复正常
		var tween = create_tween()
		tween.tween_property(visual, "color", Color(0.15, 0.15, 0.2, 1.0), 0.2)

func _animate_open():
	is_animating = true
	
	match door_type:
		DoorType.SLIDING:
			_slide_open()
		DoorType.ROTATING:
			_rotate_open()
		DoorType.DISAPPEARING:
			_disappear()
		DoorType.LOCKED:
			pass  # 锁定门不动

func _animate_close():
	is_animating = true
	
	match door_type:
		DoorType.SLIDING:
			_slide_close()
		DoorType.ROTATING:
			_rotate_close()
		DoorType.DISAPPEARING:
			_appear()
		DoorType.LOCKED:
			pass

func _slide_open():
	var target_pos = original_position + open_direction * open_distance
	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, animation_speed)
	tween.tween_callback(func(): is_animating = false)
	
	# 禁用碰撞
	tween.tween_callback(func(): 
		if collision_shape:
			collision_shape.disabled = true
	)

func _slide_close():
	var tween = create_tween()
	tween.tween_property(self, "position", original_position, animation_speed)
	tween.tween_callback(func(): is_animating = false)
	
	# 启用碰撞
	tween.tween_callback(func():
		if collision_shape:
			collision_shape.disabled = false
	)

func _rotate_open():
	if visual:
		var tween = create_tween()
		tween.tween_property(visual, "rotation_degrees", 90.0, animation_speed)
		tween.tween_callback(func(): is_animating = false)
	
	# 禁用碰撞
	if collision_shape:
		collision_shape.disabled = true

func _rotate_close():
	if visual:
		var tween = create_tween()
		tween.tween_property(visual, "rotation_degrees", 0.0, animation_speed)
		tween.tween_callback(func(): is_animating = false)
	
	# 启用碰撞
	if collision_shape:
		collision_shape.disabled = false

func _disappear():
	if visual:
		var tween = create_tween()
		tween.tween_property(visual, "color:a", 0.0, animation_speed)
		tween.parallel().tween_property(visual, "scale", Vector2(0.1, 0.1), animation_speed)
		tween.tween_callback(func(): is_animating = false)
	
	# 禁用碰撞
	if collision_shape:
		collision_shape.disabled = true

func _appear():
	if visual:
		var tween = create_tween()
		tween.tween_property(visual, "color:a", 1.0, animation_speed)
		tween.parallel().tween_property(visual, "scale", Vector2(1.0, 1.0), animation_speed)
		tween.tween_callback(func(): is_animating = false)
	
	# 启用碰撞
	if collision_shape:
		collision_shape.disabled = false

func _update_door_state():
	if is_open:
		if collision_shape:
			collision_shape.disabled = true
		if door_type == DoorType.DISAPPEARING and visual:
			visual.color.a = 0.0
			visual.scale = Vector2(0.1, 0.1)
	else:
		if collision_shape:
			collision_shape.disabled = false

func reset_door():
	is_open = false
	is_animating = false
	position = original_position
	_update_door_state()

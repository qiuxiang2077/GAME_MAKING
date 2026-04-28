class_name PushableBox
extends CharacterBody2D

@export var weight: int = 1
@export var push_speed: float = 100.0
@export var can_be_pulled: bool = false

var is_being_pushed: bool = false
var push_direction: Vector2 = Vector2.ZERO
var pusher: Node2D = null

@onready var visual = $Visual
@onready var collision_shape = $CollisionShape2D

func _ready():
	add_to_group("pushable")
	
	# 确保有碰撞
	if not collision_shape:
		collision_shape = CollisionShape2D.new()
		collision_shape.shape = RectangleShape2D.new()
		collision_shape.shape.size = Vector2(40, 40)
		add_child(collision_shape)

func _physics_process(delta):
	if is_being_pushed and pusher:
		# 跟随推动者移动
		var desired_pos = pusher.global_position + push_direction * 45
		var move_dir = (desired_pos - global_position).normalized()
		var distance = global_position.distance_to(desired_pos)
		
		if distance > 5:
			velocity = move_dir * push_speed
		else:
			velocity = Vector2.ZERO
		
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func start_push(by: Node2D, direction: Vector2) -> bool:
	if is_being_pushed:
		return false
	
	# 检查推动方向是否可行
	var query = PhysicsRayQueryParameters2D.new()
	query.from = global_position
	query.to = global_position + direction * 45
	query.exclude = [self]
	
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(query)
	
	if result:
		# 有障碍物，不能推动
		return false
	
	is_being_pushed = true
	pusher = by
	push_direction = direction
	
	# 视觉反馈
	if visual:
		var tween = create_tween()
		tween.tween_property(visual, "scale", Vector2(0.95, 0.95), 0.1)
	
	print("开始推动箱子")
	return true

func stop_push():
	if not is_being_pushed:
		return
	
	is_being_pushed = false
	pusher = null
	push_direction = Vector2.ZERO
	velocity = Vector2.ZERO
	
	# 视觉恢复
	if visual:
		var tween = create_tween()
		tween.tween_property(visual, "scale", Vector2(1.0, 1.0), 0.1)
	
	print("停止推动箱子")

func get_weight() -> int:
	return weight

func set_pushable(pushable: bool):
	# 可以临时禁用推动（例如箱子被锁定）
	if not pushable and is_being_pushed:
		stop_push()

func highlight(enabled: bool):
	# 高亮显示（当玩家靠近时）
	if visual:
		if enabled:
			var tween = create_tween()
			tween.tween_property(visual, "color", Color(0.9, 0.7, 0.4, 1.0), 0.2)
		else:
			var tween = create_tween()
			tween.tween_property(visual, "color", Color(0.6, 0.4, 0.2, 1.0), 0.2)

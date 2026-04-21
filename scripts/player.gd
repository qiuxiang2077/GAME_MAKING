extends CharacterBody2D

const SPEED = 200
const RUN_SPEED = 350

var is_hiding = false
var is_running = false
var is_pushing_box = false
var pushed_box: Node2D = null
var is_caught_by_enemy = false

@onready var visual = $Visual

func _ready():
	add_to_group("player")

func _physics_process(delta):
	if is_caught_by_enemy:
		velocity = Vector2.ZERO
		return
	
	# 恐惧系统影响
	var sleep_mgr = _get_sleep_manager()
	var speed_multiplier = 1.0
	var panic = false
	if sleep_mgr:
		speed_multiplier = sleep_mgr.get_fear_speed_multiplier()
		panic = sleep_mgr.is_panic_state()
	
	# 重度恐慌：随机移动
	if panic:
		velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * SPEED * 0.5
		move_and_slide()
		return
	
	# 推箱子
	if is_pushing_box and pushed_box:
		_handle_push_box()
		return
	
	# 移动控制
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	
	# 跑步控制 - 设计文档: Shift快速行走，消耗小但可能吸引敌人
	is_running = Input.is_action_pressed("run")
	var current_speed = RUN_SPEED if is_running else SPEED
	current_speed *= speed_multiplier
	
	# 跑步时通知敌人
	if is_running and input_dir != Vector2.ZERO:
		_notify_enemies_running()
	
	# 躲藏控制
	if Input.is_action_just_pressed("hide"):
		is_hiding = !is_hiding
		if is_hiding:
			if visual:
				visual.color = Color(0.2, 0.2, 0.2, 0.5)
		else:
			if visual:
				visual.color = Color(0, 0, 0, 1)
	
	if !is_hiding:
		if input_dir != Vector2.ZERO:
			input_dir = input_dir.normalized()
			velocity = input_dir * current_speed
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	
	if Input.is_action_just_pressed("interact"):
		interact()

func _get_sleep_manager():
	var root = get_tree().current_scene
	if root:
		return root.get_node_or_null("SleepManager")
	return null

func _notify_enemies_running():
	# 设计文档: 跑步可能吸引敌人
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if enemy.has_method("hear_noise"):
			var distance = global_position.distance_to(enemy.global_position)
			if distance < 400:
				enemy.hear_noise(global_position)

func _handle_push_box():
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		velocity = input_dir * SPEED
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	
	if Input.is_action_just_pressed("interact") or input_dir == Vector2.ZERO:
		_stop_push_box()

func _stop_push_box():
	if pushed_box and pushed_box.has_method("stop_push"):
		pushed_box.stop_push()
	is_pushing_box = false
	pushed_box = null

func interact():
	if is_pushing_box:
		_stop_push_box()
		return
	
	var box = _find_pushable_box()
	if box:
		_start_push_box(box)
		return
	
	print("Interact button pressed")
	
	var space_state = get_world_2d().direct_space_state if get_world_2d() else null
	if not space_state:
		return
	
	var query = PhysicsPointQueryParameters2D.new()
	query.position = global_position
	query.collision_mask = 1 << 2
	query.max_results = 10
	
	var result = space_state.intersect_point(query)
	
	if result.size() > 0:
		var body = result[0].collider
		if body.has_method("interact"):
			body.interact()
		elif body.is_in_group("collectible"):
			body.collect()

func _find_pushable_box() -> Node2D:
	var space_state = get_world_2d().direct_space_state
	if not space_state:
		return null
	
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	elif Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	elif Input.is_action_pressed("move_down"):
		input_dir.y += 1
	elif Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	
	if input_dir == Vector2.ZERO:
		var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
		for dir in directions:
			var box = _check_direction_for_box(dir)
			if box:
				return box
		return null
	
	return _check_direction_for_box(input_dir.normalized())

func _check_direction_for_box(direction: Vector2) -> Node2D:
	var space_state = get_world_2d().direct_space_state
	if not space_state:
		return null
	
	var query = PhysicsRayQueryParameters2D.new()
	query.from = global_position
	query.to = global_position + direction * 50
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	if result:
		var collider = result.collider
		if collider.is_in_group("pushable") and collider.has_method("start_push"):
			return collider
	return null

func _start_push_box(box: Node2D):
	var push_dir = (box.global_position - global_position).normalized()
	
	if abs(push_dir.x) > abs(push_dir.y):
		push_dir = Vector2.RIGHT if push_dir.x > 0 else Vector2.LEFT
	else:
		push_dir = Vector2.DOWN if push_dir.y > 0 else Vector2.UP
	
	if box.start_push(self, push_dir):
		is_pushing_box = true
		pushed_box = box

func caught_by_enemy():
	# 设计文档: 敌人发现玩家后追击，被抓住触发游戏结束
	if is_hiding:
		return
	
	is_caught_by_enemy = true
	print("被敌人抓住！")
	
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		game_manager.trigger_game_over()

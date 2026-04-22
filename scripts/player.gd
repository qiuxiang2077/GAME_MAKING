extends CharacterBody2D

const SPEED = 200
const RUN_SPEED = 350
const INTERACT_RANGE = 50

var is_running = false

var max_health = 100
var health = 100
var max_sanity = 100
var sanity = 100

signal health_updated(health, max_health)
signal sanity_updated(sanity, max_sanity)

@onready var visual = $Visual if has_node("Visual") else null
@onready var game_manager = null

# Compatibility variables (push, simple tool state)
var is_pushing_box = false
var pushed_box: Node2D = null
enum Tool { NONE, HOE, SCYTHE, WATERING_CAN }
var current_tool = Tool.NONE
var selected_seed = "wheat"

func _ready():
	# 添加到玩家组，方便查找
	add_to_group("player")
	health_updated.emit(health, max_health)
	sanity_updated.emit(sanity, max_sanity)

	# Resolve GameManager robustly
	game_manager = get_node_or_null("/root/GameManager")
	if not game_manager:
		var root = get_tree().current_scene
		if root and root.has_node("GameManager"):
			game_manager = root.get_node("GameManager")

func _physics_process(_delta):
	# 移动控制 - 俯视角，可以在X和Y轴自由移动
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	
	# 跑步控制
	is_running = Input.is_action_pressed("run")
	var current_speed = RUN_SPEED if is_running else SPEED
	
	# 移动
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		velocity = input_dir * current_speed
	else:
		velocity = Vector2.ZERO
	
	# 移动角色
	move_and_slide()
	
	# 互动控制
	if Input.is_action_just_pressed("interact"):
		interact()

func _handle_push_box():
	# 推箱子时的移动处理
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
	
	# 检查是否要停止推箱子
	if Input.is_action_just_pressed("interact") or input_dir == Vector2.ZERO:
		_stop_push_box()

func _stop_push_box():
	if pushed_box and pushed_box.has_method("stop_push"):
		pushed_box.stop_push()
	is_pushing_box = false
	pushed_box = null
	print("停止推箱子")

func interact():
	# 检测周围可互动物体
	var space_state = get_world_2d().direct_space_state if get_world_2d() else null
	if not space_state:
		print("无法获取物理空间状态")
		return
	
	var query = PhysicsPointQueryParameters2D.new()
	query.position = global_position
	query.collision_mask = 1 << 2  # 碰撞层 2
	query.max_results = 10
	
	var result = space_state.intersect_point(query)
	
	if result.size() > 0:
		var body = result[0].collider
		if body and body.has_method("interact"):
			body.interact()
			print("Interacted with: " + body.name)
		elif body and body.is_in_group("character"):
			# Narrative interaction with character
			var dialogue = game_manager.interact_with_character(body.character_name)
			print(body.character_name + ": " + dialogue)
		elif body and body.is_in_group("collectible"):
			body.collect()
			print("Collected: " + body.name)

func _find_pushable_box() -> Node2D:
	# 查找玩家面前的箱子
	var space_state = get_world_2d().direct_space_state if get_world_2d() else null
	if not space_state:
		return null
	
	# 获取输入方向
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
		# 如果没有方向输入，检查周围
		var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
		for dir in directions:
			var box = _check_direction_for_box(dir)
			if box:
				return box
		return null
	
	return _check_direction_for_box(input_dir.normalized())

func _check_direction_for_box(direction: Vector2) -> Node2D:
	var space_state = get_world_2d().direct_space_state if get_world_2d() else null
	if not space_state:
		return null
	
	var query = PhysicsRayQueryParameters2D.new()
	query.from = global_position
	query.to = global_position + direction * 50
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	if result:
		var collider = result.collider
		if collider and collider.is_in_group("pushable") and collider.has_method("start_push"):
			return collider
	
	return null

func _start_push_box(box: Node2D):
	if not box:
		return
	
	# 计算推的方向
	var push_dir = (box.global_position - global_position).normalized()
	
	# 四方向对齐
	if abs(push_dir.x) > abs(push_dir.y):
		push_dir = Vector2.RIGHT if push_dir.x > 0 else Vector2.LEFT
	else:
		push_dir = Vector2.DOWN if push_dir.y > 0 else Vector2.UP
	
	if box.start_push(self, push_dir):
		is_pushing_box = true
		pushed_box = box
		print("开始推箱子，方向: " + str(push_dir))

func _handle_farming_interaction() -> bool:
	# Only allow farming interactions if GameManager exposes farming methods
	if not game_manager or not game_manager.has_method("plant_crop"):
		return false
	
	match current_tool:
		Tool.HOE:
			# Till soil (plant crop)
			var success = game_manager.plant_crop(selected_seed, global_position)
			if success:
				print("Planted " + selected_seed)
			else:
				print("Cannot plant here")
			return true
		Tool.SCYTHE:
			# Harvest crop
			var harvested_crop = game_manager.harvest_crop(global_position)
			if harvested_crop:
				print("Harvested " + harvested_crop)
			else:
				print("Nothing to harvest here")
			return true
		Tool.NONE:
			# Check for NPC interaction
			var npc = game_manager.npc_system.get_npc_at_position(global_position)
			if npc:
				var dialogue = game_manager.interact_with_npc(npc.name)
				print(npc.name + ": " + dialogue)
				return true
	return false

func set_tool(tool: Tool):
	current_tool = tool
	print("Switched to tool: " + Tool.keys()[tool])

func set_seed_type(seed_type: String):
	selected_seed = seed_type
	print("Selected seed: " + seed_type)

func take_damage(amount):
	health = max(0, health - amount)
	health_updated.emit(health, max_health)
	if health <= 0:
		die()

func heal(amount):
	health = min(max_health, health + amount)
	health_updated.emit(health, max_health)

func reduce_sanity(amount):
	sanity = max(0, sanity - amount)
	sanity_updated.emit(sanity, max_sanity)
	_check_sanity_effects()

func restore_sanity(amount):
	sanity = min(max_sanity, sanity + amount)
	sanity_updated.emit(sanity, max_sanity)
	_check_sanity_effects()

func _check_sanity_effects():
	# SAN值低时施加负面效果
	if sanity < 30:
		# 视野缩小、移动速度减慢等
		pass

func die():
	# 触发游戏结束
	if game_manager and game_manager.has_method("call_game_over"):
		game_manager.call_game_over()
	else:
		# Fallback: reload current scene
		get_tree().reload_current_scene()

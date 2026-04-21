extends CharacterBody2D

var SPEED = 80
var RUN_SPEED = 120
const PATROL_RANGE = 150
const CHASE_RANGE = 300
const CATCH_RANGE = 20

enum EnemyType {
	PATROL,
	TRACKING,
	HIDDEN,
	SENSITIVE
}

var start_position = Vector2.ZERO
var move_direction = Vector2.RIGHT
var is_patrolling = true
var has_detected_player = false
var enemy_type = EnemyType.PATROL
var chase_timer = 0
var chase_duration = 5.0
var last_known_player_pos = Vector2.ZERO

@onready var detection_area = $DetectionArea
@onready var visual = $Visual

func _ready():
	start_position = position
	add_to_group("enemy")
	
	var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	move_direction = directions[randi() % directions.size()]
	
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_entered)
		detection_area.body_exited.connect(_on_detection_area_exited)

func _physics_process(delta):
	if is_patrolling:
		patrol_behavior()
	elif has_detected_player:
		chase_behavior()
		chase_timer += delta
		if chase_timer > chase_duration:
			reset_to_patrol()
	
	move_and_slide()
	
	# 检查是否抓住玩家
	_check_catch_player()

func patrol_behavior():
	velocity = move_direction * SPEED
	
	if (position - start_position).length() > PATROL_RANGE:
		change_direction()

func chase_behavior():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var distance = (player.global_position - global_position).length()
		if distance < CHASE_RANGE:
			move_direction = (player.global_position - global_position).normalized()
			velocity = move_direction * RUN_SPEED
			last_known_player_pos = player.global_position
		else:
			# 超出追踪范围，前往最后已知位置
			var to_last_pos = (last_known_player_pos - global_position)
			if to_last_pos.length() < 10:
				reset_to_patrol()
			else:
				move_direction = to_last_pos.normalized()
				velocity = move_direction * RUN_SPEED
	else:
		reset_to_patrol()

func _check_catch_player():
	# 设计文档: 敌人追击玩家，被抓住触发游戏结束
	var player = get_tree().get_first_node_in_group("player")
	if player and has_detected_player:
		var distance = global_position.distance_to(player.global_position)
		if distance < CATCH_RANGE:
			if player.has_method("caught_by_enemy"):
				player.caught_by_enemy()

func change_direction():
	var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	move_direction = directions[randi() % directions.size()]
	start_position = position

func reset_to_patrol():
	has_detected_player = false
	is_patrolling = true
	chase_timer = 0
	
	if visual:
		var tween = create_tween()
		tween.tween_property(visual, "color", Color(0.8, 0.2, 0.2, 1), 0.2)
		tween.tween_property(visual, "scale", Vector2(1.0, 1.0), 0.2)

func _on_detection_area_entered(body):
	if body.name == "Player" and not has_detected_player:
		# 设计文档: 躲藏时不被发现
		if not body.is_hiding:
			detect_player()

func _on_detection_area_exited(body):
	if body.name == "Player" and has_detected_player:
		chase_timer = 0

func detect_player():
	has_detected_player = true
	is_patrolling = false
	print("敌人发现玩家！")
	
	if visual:
		var tween = create_tween()
		tween.tween_property(visual, "color", Color(1, 0.5, 0.5, 1), 0.2)
		tween.tween_property(visual, "scale", Vector2(1.3, 1.3), 0.2)

func hear_noise(source_position: Vector2):
	# 设计文档: 感应型敌人对声音敏感，跑步可能吸引敌人
	if enemy_type == EnemyType.SENSITIVE:
		last_known_player_pos = source_position
		if not has_detected_player:
			detect_player()
	elif enemy_type == EnemyType.PATROL:
		# 巡逻型敌人对声音有轻微反应
		var distance = global_position.distance_to(source_position)
		if distance < 200:
			last_known_player_pos = source_position

func set_enemy_type(type):
	enemy_type = type
	match enemy_type:
		EnemyType.HIDDEN:
			is_patrolling = false
			velocity = Vector2.ZERO
		EnemyType.SENSITIVE:
			self.SPEED = 90
		EnemyType.TRACKING:
			self.RUN_SPEED = 150

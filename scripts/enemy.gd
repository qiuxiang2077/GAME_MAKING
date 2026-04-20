extends CharacterBody2D

var SPEED = 80
var RUN_SPEED = 120
const PATROL_RANGE = 150
const CHASE_RANGE = 300

# 敌人类型枚举
enum EnemyType {
	PATROL,     # 巡逻型
	TRACKING,   # 追踪型
	HIDDEN,     # 潜伏型
	SENSITIVE   # 感应型
}

var start_position = Vector2.ZERO
var move_direction = Vector2.RIGHT
var is_patrolling = true
var has_detected_player = false
var enemy_type = EnemyType.PATROL
var chase_timer = 0
var chase_duration = 5.0

@onready var detection_area = $DetectionArea
@onready var visual = $Visual

func _ready():
	start_position = position
	# 随机选择初始方向
	var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	move_direction = directions[randi() % directions.size()]
	
	# 连接检测区域信号
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

func patrol_behavior():
	velocity = move_direction * SPEED
	
	# 检查巡逻边界
	if (position - start_position).length() > PATROL_RANGE:
		change_direction()

func chase_behavior():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var distance = (player.global_position - global_position).length()
		if distance < CHASE_RANGE:
			move_direction = (player.global_position - global_position).normalized()
			velocity = move_direction * RUN_SPEED
		else:
			reset_to_patrol()
	else:
		reset_to_patrol()

func change_direction():
	var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	move_direction = directions[randi() % directions.size()]
	start_position = position

func reset_to_patrol():
	has_detected_player = false
	is_patrolling = true
	chase_timer = 0
	
	# 视觉反馈 - 敌人恢复正常状态
	if visual:
		var tween = create_tween()
		tween.tween_property(visual, "color", Color(0.8, 0.2, 0.2, 1), 0.2)
		tween.tween_property(visual, "scale", Vector2(1.0, 1.0), 0.2)

func _on_detection_area_entered(body):
	if body.name == "Player" and not has_detected_player:
		detect_player()

func _on_detection_area_exited(body):
	if body.name == "Player" and has_detected_player:
		chase_timer = 0

func detect_player():
	has_detected_player = true
	is_patrolling = false
	print("敌人发现玩家！")
	
	# 视觉反馈 - 敌人变亮并停止巡逻
	if visual:
		var tween = create_tween()
		tween.tween_property(visual, "color", Color(1, 0.5, 0.5, 1), 0.2)
		tween.tween_property(visual, "scale", Vector2(1.3, 1.3), 0.2)

func set_enemy_type(type):
	enemy_type = type
	# 根据敌人类型设置不同行为
	match enemy_type:
		EnemyType.HIDDEN:
			# 潜伏型敌人：静止不动，发现后追击
			is_patrolling = false
			velocity = Vector2.ZERO
		EnemyType.SENSITIVE:
			# 感应型敌人：对声音敏感
			self.SPEED = 90
		EnemyType.TRACKING:
			# 追踪型敌人：更快的追击速度
			self.RUN_SPEED = 150

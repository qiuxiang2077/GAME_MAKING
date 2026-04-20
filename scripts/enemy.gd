extends CharacterBody2D

const SPEED = 80
const PATROL_RANGE = 150

var start_position = Vector2.ZERO
var move_direction = Vector2.RIGHT
var is_patrolling = true
var has_detected_player = false

func _ready():
	start_position = position
	# 随机选择初始方向
	var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	move_direction = directions[randi() % directions.size()]
	
	# 连接检测区域信号
	$DetectionArea.body_entered.connect(_on_detection_area_entered)

func _physics_process(delta):
	if is_patrolling:
		velocity = move_direction * SPEED
		
		# 检查巡逻边界
		if (position - start_position).length() > PATROL_RANGE:
			change_direction()
	
	move_and_slide()

func change_direction():
	var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	move_direction = directions[randi() % directions.size()]
	start_position = position

func _on_detection_area_entered(body):
	if body.name == "Player" and not has_detected_player:
		detect_player()

func detect_player():
	has_detected_player = true
	print("敌人发现玩家！")
	
	# 视觉反馈 - 敌人变亮并停止巡逻
	var tween = create_tween()
	tween.tween_property($Visual, "color", Color(1, 0.5, 0.5, 1), 0.2)
	tween.tween_property($Visual, "scale", Vector2(1.3, 1.3), 0.2)
	
	# 停止巡逻
	is_patrolling = false
	velocity = Vector2.ZERO
	
	# 向玩家方向追击（简化版）
	var player = get_tree().get_first_node_in_group("player")
	if player:
		move_direction = (player.global_position - global_position).normalized()
	
	# 触发游戏结束
	GameManager.trigger_game_over()

extends CharacterBody2D

const SPEED = 80
const PATROL_RANGE = 150

var start_position = Vector2.ZERO
var move_direction = Vector2.RIGHT  # 初始向右移动
var is_patrolling = true

func _ready():
	start_position = position
	# 随机选择一个初始方向
	var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	move_direction = directions[randi() % directions.size()]

func _physics_process(delta):
	if is_patrolling:
		# 巡逻逻辑 - 俯视角，可以在任意方向移动
		velocity = move_direction * SPEED
		
		# 检查是否到达巡逻边界
		if (position - start_position).length() > PATROL_RANGE:
			# 改变方向
			change_direction()
	
	move_and_slide()

func change_direction():
	# 随机选择一个新方向
	var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	move_direction = directions[randi() % directions.size()]
	start_position = position  # 重置起点

func _on_area_entered(area):
	# 检测玩家
	if area.name == "Player":
		print("Enemy detected player")

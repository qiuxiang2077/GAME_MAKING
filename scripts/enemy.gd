extends CharacterBody2D

const SPEED = 100
const PATROL_RANGE = 100

var start_position = Vector2.ZERO
var move_direction = 1  # 1 for right, -1 for left
var is_patrolling = true

func _ready():
	start_position = position

func _physics_process(delta):
	if is_patrolling:
		# 巡逻逻辑
		velocity.x = move_direction * SPEED
		
		# 检查是否到达巡逻边界
		if abs(position.x - start_position.x) > PATROL_RANGE:
			move_direction *= -1
			# 翻转敌人
			$ColorRect.scale.x = -$ColorRect.scale.x
	
	move_and_slide()

func _on_area_entered(area):
	# 检测玩家
	if area.name == "Player":
		# 这里可以添加追逐逻辑
		print("Enemy detected player")

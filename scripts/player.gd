extends CharacterBody2D

const SPEED = 200
const RUN_SPEED = 350

var is_hiding = false
var is_running = false

func _ready():
	pass

func _physics_process(delta):
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
	
	# 躲藏控制
	if Input.is_action_just_pressed("hide"):
		is_hiding = !is_hiding
		if is_hiding:
			# 躲藏时视觉反馈
			$ColorRect.color = Color(0.2, 0.2, 0.2, 0.5)
		else:
			# 取消躲藏
			$ColorRect.color = Color(0, 0, 0, 1)
	
	# 只有在不躲藏时才能移动
	if !is_hiding:
		if input_dir != Vector2.ZERO:
			input_dir = input_dir.normalized()
			velocity = input_dir * current_speed
		else:
			# 停止移动
			velocity = Vector2.ZERO
	else:
		# 躲藏时不能移动
		velocity = Vector2.ZERO
	
	# 互动控制
	if Input.is_action_just_pressed("interact"):
		interact()
	
	# 移动角色
	move_and_slide()

func interact():
	# 实现互动逻辑
	print("Interact button pressed")
	# 这里可以添加与物体互动的代码

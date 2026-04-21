extends CanvasLayer

func _ready():
	# 获取按钮引用
	var start_button = get_node("Control/ButtonContainer/StartButton")
	var quit_button = get_node("Control/ButtonContainer/QuitButton")
	
	# 连接信号
	start_button.pressed.connect(_on_start_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed():
	# 切换到游戏场景
	get_tree().change_scene_to_file("res://scenes/maze_level.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
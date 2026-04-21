class_name VisionSystem
extends Node2D

@export var base_view_radius: float = 300.0
@export var min_view_radius: float = 120.0
@export var fear_effect_multiplier: float = 2.0

var current_view_radius: float = base_view_radius
var darkness_overlay: ColorRect = null
var light_2d: Light2D = null

func _ready():
	_setup_vision_overlay()

func _setup_vision_overlay():
	# 创建黑暗遮罩
	darkness_overlay = ColorRect.new()
	darkness_overlay.color = Color(0, 0, 0, 0.85)
	darkness_overlay.size = Vector2(2000, 2000)
	darkness_overlay.position = Vector2(-1000, -1000)
	darkness_overlay.z_index = 50
	add_child(darkness_overlay)
	
	# 创建2D灯光作为视野光源
	light_2d = Light2D.new()
	light_2d.texture = _create_light_texture()
	light_2d.energy = 1.0
	light_2d.scale = Vector2(1, 1)
	light_2d.z_index = 51
	light_2d.mode = Light2D.LIGHT_MODE_MASK
	add_child(light_2d)

func _create_light_texture() -> GradientTexture2D:
	var gradient = GradientTexture2D.new()
	gradient.width = 512
	gradient.height = 512
	gradient.fill = GradientTexture2D.FILL_RADIAL
	gradient.fill_from = Vector2(0.5, 0.5)
	gradient.fill_to = Vector2(1.0, 0.5)
	
	var color_gradient = Gradient.new()
	color_gradient.add_point(0.0, Color(1, 1, 1, 1))
	color_gradient.add_point(0.5, Color(1, 1, 1, 0.5))
	color_gradient.add_point(1.0, Color(1, 1, 1, 0))
	gradient.gradient = color_gradient
	
	return gradient

func update_vision(player_position: Vector2, fear_level: float, stage: int):
	if stage != 2:  # 不是深睡期
		darkness_overlay.visible = false
		light_2d.visible = false
		return
	
	darkness_overlay.visible = true
	light_2d.visible = true
	
	# 根据恐惧值计算视野半径
	var fear_ratio = fear_level / 100.0
	current_view_radius = lerp(base_view_radius, min_view_radius, fear_ratio * fear_effect_multiplier)
	current_view_radius = max(current_view_radius, min_view_radius)
	
	# 更新灯光位置和大小
	light_2d.global_position = player_position
	light_2d.scale = Vector2(current_view_radius / 256.0, current_view_radius / 256.0)
	
	# 根据恐惧值调整黑暗强度
	var darkness_alpha = lerp(0.6, 0.95, fear_ratio)
	darkness_overlay.color.a = darkness_alpha

func set_full_vision():
	darkness_overlay.visible = false
	light_2d.visible = false

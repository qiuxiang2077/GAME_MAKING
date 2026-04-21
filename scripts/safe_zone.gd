class_name SafeZone
extends Area2D

signal player_entered_safe_zone()
signal player_exited_safe_zone()

@export var fear_reduction_rate: float = 2.0
@export var heal_amount: int = 0

var player_in_zone: bool = false
var reduction_timer: Timer = null

@onready var visual = $Visual
@onready var glow = $Glow

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	reduction_timer = Timer.new()
	reduction_timer.wait_time = 0.5
	reduction_timer.autostart = false
	reduction_timer.timeout.connect(_reduce_fear)
	add_child(reduction_timer)
	
	_animate_idle()

func _on_body_entered(body):
	if body.name == "Player":
		player_in_zone = true
		reduction_timer.start()
		player_entered_safe_zone.emit()
		_animate_active()
		print("进入安全点")

func _on_body_exited(body):
	if body.name == "Player":
		player_in_zone = false
		reduction_timer.stop()
		player_exited_safe_zone.emit()
		_animate_idle()
		print("离开安全点")

func _reduce_fear():
	var sleep_mgr = _get_sleep_manager()
	if sleep_mgr and player_in_zone:
		sleep_mgr.reduce_fear(fear_reduction_rate)

func _get_sleep_manager():
	var root = get_tree().current_scene
	if root:
		return root.get_node_or_null("SleepManager")
	return null

func _animate_idle():
	if visual:
		var tween = create_tween()
		tween.tween_property(visual, "color", Color(0.3, 0.5, 0.8, 0.4), 1.0)
	if glow:
		var tween2 = create_tween()
		tween2.tween_property(glow, "color:a", 0.1, 1.0)

func _animate_active():
	if visual:
		var tween = create_tween()
		tween.tween_property(visual, "color", Color(0.4, 0.7, 1.0, 0.6), 0.5)
	if glow:
		var tween2 = create_tween()
		tween2.tween_property(glow, "color:a", 0.3, 0.5)

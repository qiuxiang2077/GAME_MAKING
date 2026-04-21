class_name ItemSystem
extends Node

enum ItemType {
	CALMING,      # 安抚道具 - 安抚敌人
	LIGHT,        # 照明道具 - 增加视野
	PROTECTION,   # 保护道具 - 抵挡一次伤害
	MEMORY        # 记忆道具 - 显示碎片位置
}

var inventory: Dictionary = {}
var max_stack: int = 99

signal item_collected(item_type, amount)
signal item_used(item_type)
signal inventory_changed()

func _ready():
	# 初始化空背包
	for type in ItemType.values():
		inventory[type] = 0

func add_item(item_type: ItemType, amount: int = 1) -> bool:
	if inventory[item_type] + amount > max_stack:
		return false
	
	inventory[item_type] += amount
	item_collected.emit(item_type, amount)
	inventory_changed.emit()
	print("获得道具: " + _get_item_name(item_type) + " x" + str(amount))
	return true

func use_item(item_type: ItemType) -> bool:
	if inventory[item_type] <= 0:
		return false
	
	var success = _apply_item_effect(item_type)
	if success:
		inventory[item_type] -= 1
		item_used.emit(item_type)
		inventory_changed.emit()
		print("使用道具: " + _get_item_name(item_type))
	return success

func _apply_item_effect(item_type: ItemType) -> bool:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return false
	
	match item_type:
		ItemType.CALMING:
			return _use_calming_item(player)
		ItemType.LIGHT:
			return _use_light_item(player)
		ItemType.PROTECTION:
			return _use_protection_item(player)
		ItemType.MEMORY:
			return _use_memory_item(player)
	
	return false

func _use_calming_item(player) -> bool:
	# 安抚附近的敌人
	var emotion_system = get_node_or_null("/root/EmotionSystem")
	if not emotion_system:
		return false
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	var calmed_any = false
	
	for enemy in enemies:
		if player.global_position.distance_to(enemy.global_position) < 150:
			if emotion_system.calm_enemy(enemy):
				calmed_any = true
	
	return calmed_any

func _use_light_item(player) -> bool:
	# 临时增加视野（在深睡期有效）
	var vision_system = get_node_or_null("/root/VisionSystem")
	if vision_system:
		vision_system.base_view_radius = min(vision_system.base_view_radius + 100, 500)
		
		# 5秒后恢复
		var timer = get_tree().create_timer(5.0)
		timer.timeout.connect(func():
			if is_instance_valid(vision_system):
				vision_system.base_view_radius = max(vision_system.base_view_radius - 100, 300)
		)
		return true
	return false

func _use_protection_item(player) -> bool:
	# 给玩家添加保护状态
	player.set_meta("protected", true)
	
	# 显示保护效果
	if player.has_node("Visual"):
		var visual = player.get_node("Visual")
		var tween = create_tween()
		tween.tween_property(visual, "color", Color(0.5, 0.8, 1.0, 1), 0.3)
	
	print("获得保护护盾！")
	return true

func _use_memory_item(player) -> bool:
	# 高亮显示附近的记忆碎片
	var collectibles = get_tree().get_nodes_in_group("collectible")
	var highlighted = false
	
	for collectible in collectibles:
		if is_instance_valid(collectible) and collectible.has_node("Glow"):
			var glow = collectible.get_node("Glow")
			var tween = create_tween()
			tween.tween_property(glow, "color:a", 0.8, 0.5)
			tween.tween_property(glow, "color:a", 0.15, 3.0)
			highlighted = true
	
	return highlighted

func get_item_count(item_type: ItemType) -> int:
	return inventory[item_type]

func has_item(item_type: ItemType) -> bool:
	return inventory[item_type] > 0

func _get_item_name(item_type: ItemType) -> String:
	match item_type:
		ItemType.CALMING: return "安抚香囊"
		ItemType.LIGHT: return "萤火灯笼"
		ItemType.PROTECTION: return "守护护符"
		ItemType.MEMORY: return "记忆罗盘"
		_: return "未知道具"

func get_item_description(item_type: ItemType) -> String:
	match item_type:
		ItemType.CALMING: return "安抚附近的情绪怪物"
		ItemType.LIGHT: return "临时增加视野范围"
		ItemType.PROTECTION: return "抵挡一次敌人攻击"
		ItemType.MEMORY: return "显示附近的记忆碎片"
		_: return ""

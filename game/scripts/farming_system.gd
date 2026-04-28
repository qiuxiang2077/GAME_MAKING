extends Node

# Farming system for crop planting, growth, and harvesting
# Integrates with time system for crop growth

# Crop data structure
class Crop:
	var type: String
	var growth_time: int  # in days
	var current_growth: int = 0
	var harvestable: bool = false
	var position: Vector2
	
	func _init(crop_type: String, pos: Vector2):
		type = crop_type
		position = pos
		# Set growth time based on crop type
		match type:
			"wheat":
				growth_time = 4
			"carrot":
				growth_time = 3
			"potato":
				growth_time = 5
			_:
				growth_time = 3

# Farm state
var planted_crops: Array[Crop] = []
var inventory: Dictionary = {}  # crop_type -> count

# Signals
signal crop_planted(crop: Crop)
signal crop_grew(crop: Crop)
signal crop_harvested(crop: Crop, amount: int)
signal inventory_updated(inventory: Dictionary)

@onready var time_system = null

func _ready():
	# Resolve time system robustly
	time_system = get_node_or_null("/root/GameManager/TimeSystem")
	if not time_system:
		var gm = get_node_or_null("/root/GameManager")
		if gm and gm.has_method("time_system"):
			time_system = gm.time_system
	if time_system and time_system.has_method("day_changed"):
		time_system.day_changed.connect(_on_day_changed)

func plant_crop(crop_type: String, position: Vector2) -> bool:
	# Check if position is already occupied
	for crop in planted_crops:
		if crop.position == position:
			return false  # Already planted
	
	# Create new crop
	var new_crop = Crop.new(crop_type, position)
	planted_crops.append(new_crop)
	crop_planted.emit(new_crop)
	return true

func harvest_crop(position: Vector2) -> String:
	for i in range(planted_crops.size()):
		var crop = planted_crops[i]
		if crop.position == position and crop.harvestable:
			var crop_type = crop.type
			var harvest_amount = randi_range(1, 3)  # Random harvest amount
			
			# Add to inventory
			if not inventory.has(crop_type):
				inventory[crop_type] = 0
			inventory[crop_type] += harvest_amount
			
			planted_crops.remove_at(i)
			crop_harvested.emit(crop, harvest_amount)
			inventory_updated.emit(inventory)
			return crop_type
	
	return ""  # No harvestable crop found

func _on_day_changed(_new_day: int):
	# Grow crops each day
	for crop in planted_crops:
		if not crop.harvestable:
			crop.current_growth += 1
			if crop.current_growth >= crop.growth_time:
				crop.harvestable = true
				crop_grew.emit(crop)

func get_crop_at_position(position: Vector2) -> Crop:
	for crop in planted_crops:
		if crop.position == position:
			return crop
	return null

func get_inventory_count(crop_type: String) -> int:
	return inventory.get(crop_type, 0)

func sell_crop(crop_type: String, amount: int) -> int:
	if inventory.get(crop_type, 0) >= amount:
		inventory[crop_type] -= amount
		var price = get_crop_price(crop_type)
		inventory_updated.emit(inventory)
		return price * amount
	return 0

func get_crop_price(crop_type: String) -> int:
	match crop_type:
		"wheat":
			return 25
		"carrot":
			return 35
		"potato":
			return 40
		_:
			return 20
extends Node

# NPC system for village interactions and relationships
# Inspired by Stardew Valley social mechanics

# NPC data structure
class NPC:
	var name: String
	var relationship_level: int = 0  # 0-10, affects dialogue and gifts
	var location: Vector2
	var schedule: Dictionary  # time -> position
	var dialogue: Dictionary  # relationship_level -> [dialogues]
	
	func _init(npc_name: String, start_pos: Vector2):
		name = npc_name
		location = start_pos
		# Initialize basic dialogue
		dialogue[0] = ["Hello there!", "Nice weather today."]
		dialogue[5] = ["Good to see you!", "How are you doing?"]
		dialogue[10] = ["My friend! Always great to talk to you."]

# NPC instances
var npcs: Array[NPC] = []

# Signals
signal npc_interacted(npc: NPC, dialogue: String)
signal relationship_changed(npc: NPC, new_level: int)

func _ready():
	# Initialize some NPCs
	create_npcs()

func create_npcs():
	var npc1 = NPC.new("Farmer Joe", Vector2(100, 100))
	npc1.schedule = {
		"morning": Vector2(100, 100),
		"afternoon": Vector2(200, 150),
		"evening": Vector2(50, 50)
	}
	npcs.append(npc1)
	
	var npc2 = NPC.new("Shopkeeper Mary", Vector2(300, 200))
	npc2.schedule = {
		"morning": Vector2(300, 200),
		"afternoon": Vector2(300, 200),
		"evening": Vector2(250, 180)
	}
	npcs.append(npc2)

func interact_with_npc(npc_name: String) -> String:
	for npc in npcs:
		if npc.name == npc_name:
			# Get appropriate dialogue based on relationship
			var level = npc.relationship_level
			var dialogues = npc.dialogue.get(level, npc.dialogue[0])
			var selected_dialogue = dialogues[randi() % dialogues.size()]
			
			# Slightly increase relationship on interaction
			npc.relationship_level = min(10, npc.relationship_level + 1)
			relationship_changed.emit(npc, npc.relationship_level)
			
			npc_interacted.emit(npc, selected_dialogue)
			return selected_dialogue
	return "NPC not found."

func give_gift(npc_name: String, gift_type: String) -> String:
	for npc in npcs:
		if npc.name == npc_name:
			var gift_value = get_gift_value(gift_type, npc.name)
			npc.relationship_level = clamp(npc.relationship_level + gift_value, 0, 10)
			relationship_changed.emit(npc, npc.relationship_level)
			
			var response = get_gift_response(gift_value)
			return response
	return "NPC not found."

func get_gift_value(gift_type: String, _npc_name: String) -> int:
	# Simple gift system - can be expanded
	match gift_type:
		"wheat":
			return 1
		"carrot":
			return 2
		"potato":
			return 2
		_:
			return 0

func get_gift_response(gift_value: int) -> String:
	if gift_value >= 2:
		return "Oh, how thoughtful! Thank you!"
	elif gift_value == 1:
		return "Thanks for the gift!"
	else:
		return "Hmm, not sure about this..."

func get_npc_at_position(position: Vector2) -> NPC:
	for npc in npcs:
		if npc.location.distance_to(position) < 50:  # Interaction range
			return npc
	return null

func update_npc_positions():
	# This would be called by time system to move NPCs according to schedule
	# For now, keep them static
	pass
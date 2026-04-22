extends Area2D

# Character node for narrative interactions

@export var character_name: String = "Character"
@export var character_description: String = "A character in the story"

var character_object: Character

func _ready():
	# Create character object
	character_object = load("res://scripts/character.gd").new(character_name, character_description, global_position)
	add_to_group("character")

func _process(delta):
	# Update character location
	if character_object:
		character_object.update_location(global_position)

func get_character() -> Character:
	return character_object
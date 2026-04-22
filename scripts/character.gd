class_name Character
extends Node

# Character object for narrative-driven gameplay
# Represents main characters in the story

enum Relationship { STRANGER, ACQUAINTANCE, FRIEND, CLOSE_FRIEND, FAMILY }

var name: String
var description: String
var relationship: Relationship = Relationship.STRANGER
var dialogue_tree: Dictionary = {}  # relationship level -> [dialogues]
var memories: Array = []  # collected memories about this character
var location: Vector2
var is_active: bool = true  # whether character is currently in the scene

signal relationship_changed(new_level: Relationship)
signal memory_added(memory: String)

func _init(char_name: String, char_description: String, start_location: Vector2):
	name = char_name
	description = char_description
	location = start_location
	_initialize_dialogue()

func _initialize_dialogue():
	# Base dialogue for different relationship levels
	dialogue_tree[Relationship.STRANGER] = [
		"...",
		"I don't know you well.",
		"Who are you?"
	]
	
	dialogue_tree[Relationship.ACQUAINTANCE] = [
		"Hello there.",
		"Nice to meet you.",
		"How are you doing?"
	]
	
	dialogue_tree[Relationship.FRIEND] = [
		"It's good to see you.",
		"I consider you a friend.",
		"Let's talk sometime."
	]
	
	dialogue_tree[Relationship.CLOSE_FRIEND] = [
		"You're very important to me.",
		"I trust you completely.",
		"We've been through so much together."
	]
	
	dialogue_tree[Relationship.FAMILY] = [
		"You're like family to me.",
		"I love you.",
		"Family means everything."
	]

func get_current_dialogue() -> String:
	var dialogues = dialogue_tree.get(relationship, dialogue_tree[Relationship.STRANGER])
	if dialogues.size() > 0:
		return dialogues[randi() % dialogues.size()]
	return "..."

func improve_relationship():
	if relationship < Relationship.FAMILY:
		relationship += 1
		relationship_changed.emit(relationship)

func add_memory(memory_text: String):
	memories.append(memory_text)
	memory_added.emit(memory_text)

func get_relationship_name() -> String:
	match relationship:
		Relationship.STRANGER:
			return "Stranger"
		Relationship.ACQUAINTANCE:
			return "Acquaintance"
		Relationship.FRIEND:
			return "Friend"
		Relationship.CLOSE_FRIEND:
			return "Close Friend"
		Relationship.FAMILY:
			return "Family"
	return "Unknown"

func update_location(new_location: Vector2):
	location = new_location
extends Node

# Narrative system for literary, story-driven gameplay
# Manages story progression, character interactions, and atmospheric elements

var characters: Dictionary = {}  # name -> Character
var current_chapter: int = 1
var story_progress: float = 0.0  # 0.0 to 1.0

# Atmospheric elements
var current_mood: String = "contemplative"
var environmental_effects: Array = []

signal chapter_changed(new_chapter: int)
signal story_progressed(progress: float)
signal mood_changed(new_mood: String)
signal character_interacted(character: Character, dialogue: String)

func _ready():
	_initialize_characters()
	_initialize_story()

func _initialize_characters():
	# Create main characters
	var boy = load("res://scripts/character.gd").new("Little Boy", "A young boy with a gentle heart and many worries.", Vector2(512, 384))
	characters["boy"] = boy
	
	var shadow = load("res://scripts/character.gd").new("Shadow Companion", "A mysterious shadow that guides and protects.", Vector2(500, 400))
	characters["shadow"] = shadow
	
	# Connect signals
	for char in characters.values():
		char.relationship_changed.connect(_on_relationship_changed.bind(char))
		char.memory_added.connect(_on_memory_added.bind(char))

func _initialize_story():
	# Set up initial story state
	current_chapter = 1
	story_progress = 0.0
	current_mood = "introspective"

func interact_with_character(character_name: String) -> String:
	if characters.has(character_name):
		var char = characters[character_name]
		var dialogue = char.get_current_dialogue()
		character_interacted.emit(char, dialogue)
		
		# Improve relationship slightly on interaction
		char.improve_relationship()
		
		# Progress story based on interaction
		_progress_story(0.05)
		
		return dialogue
	return "Character not found."

func add_character_memory(character_name: String, memory: String):
	if characters.has(character_name):
		characters[character_name].add_memory(memory)
		_progress_story(0.1)

func _progress_story(amount: float):
	story_progress = clamp(story_progress + amount, 0.0, 1.0)
	story_progressed.emit(story_progress)
	
	# Check for chapter advancement
	if story_progress >= current_chapter * 0.25:
		advance_chapter()

func advance_chapter():
	current_chapter += 1
	chapter_changed.emit(current_chapter)
	
	# Change mood based on chapter
	match current_chapter:
		2:
			set_mood("melancholic")
		3:
			set_mood("hopeful")
		4:
			set_mood("redemptive")

func set_mood(new_mood: String):
	current_mood = new_mood
	mood_changed.emit(new_mood)
	
	# Apply atmospheric effects based on mood
	_apply_mood_effects()

func _apply_mood_effects():
	# Clear previous effects
	for effect in environmental_effects:
		if is_instance_valid(effect):
			effect.queue_free()
	environmental_effects.clear()
	
	# Add new effects based on mood
	match current_mood:
		"introspective":
			# Soft lighting, gentle particles
			pass
		"melancholic":
			# Dimmer lighting, falling leaves
			pass
		"hopeful":
			# Brighter colors, floating lights
			pass
		"redemptive":
			# Warm glow, healing particles
			pass

func get_character_relationship(character_name: String) -> String:
	if characters.has(character_name):
		return characters[character_name].get_relationship_name()
	return "Unknown"

func get_story_summary() -> String:
	var summary = "Chapter " + str(current_chapter) + " - Progress: " + str(int(story_progress * 100)) + "%\n"
	summary += "Mood: " + current_mood.capitalize() + "\n\n"
	
	for char_name in characters.keys():
		var char = characters[char_name]
		summary += char_name.capitalize() + ": " + char.get_relationship_name() + "\n"
		if char.memories.size() > 0:
			summary += "  Memories: " + str(char.memories.size()) + "\n"
	
	return summary

func _on_relationship_changed(new_level, character: Character):
	print("Relationship with " + character.name + " improved to " + character.get_relationship_name())

func _on_memory_added(memory: String, character: Character):
	print("New memory about " + character.name + ": " + memory)
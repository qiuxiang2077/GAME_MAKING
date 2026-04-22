extends Node

# Game Manager for literary, narrative-driven gameplay
# Manages story progression, characters, and atmospheric elements

# Game state
var story_progress: float = 0.0
var current_mood: String = "contemplative"
var collected_memories: Array = []

# Subsystems
@onready var narrative_system = $NarrativeSystem
@onready var time_system = $TimeSystem

# Signals
signal story_progressed(progress: float)
signal mood_changed(new_mood: String)
signal memory_collected(memory: String)

func _ready():
	story_progress = 0.0
	current_mood = "contemplative"
	collected_memories = []
	
	# Initialize subsystems
	if not narrative_system:
		narrative_system = load("res://scripts/narrative_system.gd").new()
		add_child(narrative_system)
	if not time_system:
		time_system = load("res://scripts/time_system.gd").new()
		add_child(time_system)
	
	# Connect signals
	narrative_system.story_progressed.connect(_on_story_progressed)
	narrative_system.mood_changed.connect(_on_mood_changed)
	narrative_system.character_interacted.connect(_on_character_interacted)

func collect_memory(memory_text: String):
	collected_memories.append(memory_text)
	memory_collected.emit(memory_text)
	
	# Progress story
	narrative_system.add_character_memory("boy", memory_text)  # Assuming memories are about the boy

func interact_with_character(character_name: String) -> String:
	return narrative_system.interact_with_character(character_name)

func get_story_summary() -> String:
	return narrative_system.get_story_summary()

func set_mood(new_mood: String):
	narrative_system.set_mood(new_mood)

func _on_story_progressed(progress: float):
	story_progress = progress
	story_progressed.emit(progress)

func _on_mood_changed(new_mood: String):
	current_mood = new_mood
	mood_changed.emit(new_mood)

func _on_character_interacted(character: Character, dialogue: String):
	print(character.name + ": " + dialogue)


func load_next_level():
	current_level += 1
	if current_level > level_scenes.size():
		current_level = 1
	
	var next_scene_path = level_scenes[current_level - 1]
	
	reset_game()
	
	var error = get_tree().change_scene_to_file(next_scene_path)
	if error != OK:
		print("加载关卡失败: ", error)
		get_tree().change_scene_to_file(level_scenes[0])

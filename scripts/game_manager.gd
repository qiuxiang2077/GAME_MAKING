extends Node

# 游戏状态
var memory_fragments = 0
var total_fragments = 7
var is_game_over = false

# 信号
signal memory_collected(count)
signal game_over()
signal all_memories_collected()

func _ready():
	memory_fragments = 0
	is_game_over = false

func add_memory_fragment():
	memory_fragments += 1
	print("记忆碎片: " + str(memory_fragments) + "/" + str(total_fragments))
	memory_collected.emit(memory_fragments)
	
	if memory_fragments >= total_fragments:
		all_memories_collected.emit()
		print("所有记忆碎片已收集！")

func reset_game():
	memory_fragments = 0
	is_game_over = false

func trigger_game_over():
	is_game_over = true
	game_over.emit()
	print("游戏结束！")

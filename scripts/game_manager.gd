extends Node

# 游戏状态
var memory_fragments = 0
var total_fragments = 7
var is_game_over = false
var current_cycle = 1
var max_cycles = 5
var dream_score = 0

# 信号
signal memory_collected(count)
signal game_over()
signal all_memories_collected()
signal cycle_completed(cycle)
signal dream_ended(score)

func _ready():
	memory_fragments = 0
	is_game_over = false
	current_cycle = 1
	dream_score = 0

func add_memory_fragment():
	memory_fragments += 1
	print("记忆碎片: " + str(memory_fragments) + "/" + str(total_fragments))
	memory_collected.emit(memory_fragments)
	
	# 增加梦境评分
	dream_score += 100
	
	if memory_fragments >= total_fragments:
		all_memories_collected.emit()
		print("所有记忆碎片已收集！")

func reset_game():
	memory_fragments = 0
	is_game_over = false
	current_cycle = 1
	dream_score = 0

func trigger_game_over():
	is_game_over = true
	game_over.emit()
	print("游戏结束！")

func complete_cycle():
	current_cycle += 1
	cycle_completed.emit(current_cycle)
	print("完成睡眠周期: " + str(current_cycle - 1))
	
	# 增加周期完成奖励
	dream_score += 50 * (current_cycle - 1)
	
	if current_cycle > max_cycles:
		end_dream()

func end_dream():
	# 计算最终评分
	var final_score = dream_score
	
	# 记忆碎片收集奖励
	var fragment_bonus = memory_fragments * 50
	final_score += fragment_bonus
	
	# 周期完成奖励
	var cycle_bonus = (max_cycles - 1) * 100
	final_score += cycle_bonus
	
	dream_ended.emit(final_score)
	print("梦境结束！最终评分: " + str(final_score))

func get_dream_quality():
	"""获取梦境质量评级"""
	var quality = ""
	var score_percentage = dream_score / 1000.0
	
	if score_percentage >= 0.9:
		quality = "完美"
	elif score_percentage >= 0.7:
		quality = "优秀"
	elif score_percentage >= 0.5:
		quality = "良好"
	elif score_percentage >= 0.3:
		quality = "一般"
	else:
		quality = "较差"
	
	return quality

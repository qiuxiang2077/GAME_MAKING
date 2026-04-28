extends Node

# Time system for Stardew Valley style gameplay
# Manages day/night cycle, seasons, and calendar progression

# Constants
const MINUTES_PER_DAY = 1440  # 24 hours * 60 minutes
const DAYS_PER_SEASON = 28
const SEASONS = ["spring", "summer", "fall", "winter"]

# Current time state
var current_season: String = "spring"
var current_day: int = 1
var current_time: int = 480  # Start at 8:00 AM (8*60)
var time_speed: float = 1.0  # Multiplier for time passage

# Signals
signal day_changed(new_day: int)
signal season_changed(new_season: String)
signal time_updated(current_time: int, is_daytime: bool)

func _ready():
	# Start the time update timer
	var timer = Timer.new()
	timer.wait_time = 1.0  # Update every second
	timer.autostart = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	add_child(timer)

func _on_timer_timeout():
	# Advance time
	current_time += int(1 * time_speed)
	
	if current_time >= MINUTES_PER_DAY:
		current_time = 0
		advance_day()
	
	# Emit time update signal
	var day_flag = is_daytime()
	time_updated.emit(current_time, day_flag)

func advance_day():
	current_day += 1
	day_changed.emit(current_day)
	
	# Check for season change
	if current_day > DAYS_PER_SEASON:
		current_day = 1
		advance_season()

func advance_season():
	var current_index = SEASONS.find(current_season)
	current_index = (current_index + 1) % SEASONS.size()
	current_season = SEASONS[current_index]
	season_changed.emit(current_season)

func is_daytime() -> bool:
	# Daytime: 6:00 AM to 10:00 PM (360 to 1320 minutes)
	return current_time >= 360 and current_time <= 1320

func get_time_string() -> String:
	var hours_f = current_time / 60.0
	var hours = int(hours_f)
	var minutes = current_time % 60
	var am_pm = "AM" if hours < 12 else "PM"
	if hours == 0:
		hours = 12
	elif hours > 12:
		hours -= 12
	return "%d:%02d %s" % [hours, minutes, am_pm]

func get_season_name() -> String:
	return current_season.capitalize()

func set_time_speed(speed: float):
	time_speed = max(0.1, speed)  # Minimum 0.1 to prevent stopping time

func pause_time():
	time_speed = 0.0

func resume_time():
	time_speed = 1.0
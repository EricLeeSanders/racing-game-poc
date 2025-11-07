extends Control

# Race states
enum RaceState {
	IDLE,
	STAGING,
	PRE_STAGE,
	STAGE,
	COUNTDOWN,
	RACING,
	FINISHED
}

var current_state = RaceState.IDLE

# Christmas tree timing
var countdown_sequence = []
var countdown_index = 0
var countdown_timer = 0.0
var staging_step = 0

# Race data
var player_reaction_time = 0.0
var opponent_reaction_time = 0.0
var player_distance = 0.0
var opponent_distance = 0.0
var race_distance = 402.0  # Quarter mile in meters (402.336m)
var player_started = false
var opponent_started = false
var player_finished = false
var opponent_finished = false
var player_finish_time = 0.0  # ET: time from launch to finish
var opponent_finish_time = 0.0  # ET: time from launch to finish
var player_finish_real_time = 0.0  # Real time when crossed finish line
var opponent_finish_real_time = 0.0  # Real time when crossed finish line
var race_timer = 0.0

# Player input
var player_launched = false
var red_light = false

# Vehicle stats (placeholder)
var player_speed = 0.0  # Current speed
var player_max_speed = 120.0  # Max speed m/s (~270 mph)
var player_acceleration = 25.0  # Acceleration m/s^2
var opponent_speed = 0.0  # Current speed
var opponent_max_speed = 122.0  # Slightly faster max speed
var opponent_acceleration = 24.5  # Slightly slower acceleration

# UI References
@onready var christmas_tree = $ChristmasTree
@onready var pre_stage_light = $ChristmasTree/PreStageLight
@onready var stage_light = $ChristmasTree/StageLight
@onready var yellow1_light = $ChristmasTree/Yellow1Light
@onready var yellow2_light = $ChristmasTree/Yellow2Light
@onready var yellow3_light = $ChristmasTree/Yellow3Light
@onready var green_light = $ChristmasTree/GreenLight
@onready var red_light_indicator = $ChristmasTree/RedLight

@onready var player_lane = $PlayerLane
@onready var opponent_lane = $OpponentLane
@onready var player_car_sprite = $PlayerLane/PlayerCar
@onready var opponent_car_sprite = $OpponentLane/OpponentCar

@onready var player_speed_label = $PlayerInfo/SpeedLabel
@onready var opponent_speed_label = $OpponentInfo/SpeedLabel

@onready var results_panel = $ResultsPanel
@onready var results_label = $ResultsPanel/ResultsLabel
@onready var restart_button = $ResultsPanel/RestartButton

func _ready():
	results_panel.hide()
	start_race()

func start_race():
	current_state = RaceState.STAGING
	countdown_timer = 1.0

	# Reset race variables
	player_speed = 0.0
	opponent_speed = 0.0
	player_distance = 0.0
	opponent_distance = 0.0
	player_started = false
	opponent_started = false
	player_finished = false
	opponent_finished = false
	player_launched = false
	red_light = false
	race_timer = 0.0

	# Reset car positions
	player_car_sprite.position.x = 10
	opponent_car_sprite.position.x = 10

	# Reset lights
	pre_stage_light.modulate = Color(0.3, 0.3, 0.3)
	stage_light.modulate = Color(0.3, 0.3, 0.3)
	yellow1_light.modulate = Color(0.3, 0.3, 0.3)
	yellow2_light.modulate = Color(0.3, 0.3, 0.3)
	yellow3_light.modulate = Color(0.3, 0.3, 0.3)
	green_light.modulate = Color(0.3, 0.3, 0.3)
	red_light_indicator.modulate = Color(0.3, 0.3, 0.3)

func _process(delta):
	match current_state:
		RaceState.STAGING:
			_process_staging(delta)
		RaceState.PRE_STAGE:
			_process_pre_stage(delta)
		RaceState.STAGE:
			_process_stage(delta)
		RaceState.COUNTDOWN:
			_process_countdown(delta)
		RaceState.RACING:
			_process_racing(delta)
		RaceState.FINISHED:
			pass

func _process_staging(delta):
	countdown_timer -= delta
	if countdown_timer <= 0:
		# Light up pre-stage
		pre_stage_light.modulate = Color.YELLOW
		current_state = RaceState.PRE_STAGE
		countdown_timer = 0.5

func _process_pre_stage(delta):
	countdown_timer -= delta
	if countdown_timer <= 0:
		# Light up stage
		stage_light.modulate = Color.YELLOW
		current_state = RaceState.STAGE
		countdown_timer = 0.5

func _process_stage(delta):
	countdown_timer -= delta
	if countdown_timer <= 0:
		# Start countdown sequence
		current_state = RaceState.COUNTDOWN
		countdown_index = 0
		countdown_timer = 0.5  # Time between each yellow light

func _process_countdown(delta):
	countdown_timer -= delta

	if countdown_timer <= 0:
		match countdown_index:
			0:
				yellow1_light.modulate = Color.YELLOW
				countdown_timer = 0.5
				countdown_index += 1
			1:
				yellow2_light.modulate = Color.YELLOW
				countdown_timer = 0.5
				countdown_index += 1
			2:
				yellow3_light.modulate = Color.YELLOW
				countdown_timer = 0.4  # Slightly shorter for last yellow
				countdown_index += 1
			3:
				# Green light!
				green_light.modulate = Color.GREEN
				current_state = RaceState.RACING
				race_timer = 0.0

				# Opponent launches with random reaction time
				opponent_reaction_time = randf_range(0.3, 0.6)

func _process_racing(delta):
	race_timer += delta

	# Handle opponent launch
	if not opponent_started and race_timer >= opponent_reaction_time:
		opponent_started = true

	# Update positions
	if player_started and not player_finished:
		# Accelerate up to max speed
		if player_speed < player_max_speed:
			player_speed += player_acceleration * delta
			player_speed = min(player_speed, player_max_speed)

		# Update distance
		player_distance += player_speed * delta
		player_speed_label.text = "Speed: %d mph" % int(player_speed * 2.237)  # m/s to mph

		# Check if finished
		if player_distance >= race_distance:
			player_distance = race_distance  # Cap at finish line
			player_finished = true
			player_finish_time = race_timer - player_reaction_time  # ET
			player_finish_real_time = race_timer  # Real time crossed

		# Update car position
		var progress = player_distance / race_distance
		player_car_sprite.position.x = progress * 800  # Scale to lane width

	if opponent_started and not opponent_finished:
		# Accelerate up to max speed
		if opponent_speed < opponent_max_speed:
			opponent_speed += opponent_acceleration * delta
			opponent_speed = min(opponent_speed, opponent_max_speed)

		# Update distance
		opponent_distance += opponent_speed * delta
		opponent_speed_label.text = "Speed: %d mph" % int(opponent_speed * 2.237)

		# Check if finished
		if opponent_distance >= race_distance:
			opponent_distance = race_distance  # Cap at finish line
			opponent_finished = true
			opponent_finish_time = race_timer - opponent_reaction_time  # ET
			opponent_finish_real_time = race_timer  # Real time crossed

		# Update car position
		var progress = opponent_distance / race_distance
		opponent_car_sprite.position.x = progress * 800

	# Check if race is finished
	if (player_finished or red_light) and opponent_finished:
		finish_race()

func _input(event):
	if not player_launched and (current_state == RaceState.COUNTDOWN or current_state == RaceState.RACING):
		if event.is_action_pressed("launch") or event.is_action_pressed("ui_up"):
			player_launched = true

			# Check for red light (launched during countdown = before green)
			if current_state == RaceState.COUNTDOWN:
				red_light = true
				red_light_indicator.modulate = Color.RED
				player_reaction_time = 0.0
			else:
				# Valid launch during racing
				player_reaction_time = race_timer
				player_started = true

func finish_race():
	current_state = RaceState.FINISHED
	results_panel.show()

	var result_text = ""

	if red_light:
		result_text = "RED LIGHT! YOU LOSE!\n\n"
		result_text += "Reaction Time: TOO SOON\n\n"
		result_text += "Opponent Time: %.3f s\n" % opponent_finish_time
		result_text += "Opponent Reaction: %.3f s" % opponent_reaction_time
	elif not player_finished and opponent_finished:
		result_text = "YOU DIDN'T FINISH! YOU LOSE!\n\n"
		result_text += "Opponent Time: %.3f s\n" % opponent_finish_time
		result_text += "Opponent Reaction: %.3f s" % opponent_reaction_time
	elif player_finished and opponent_finished:
		# Both finished - compare REAL TIMES (who crossed finish line first)
		if player_finish_real_time < opponent_finish_real_time:
			result_text = "YOU WIN!\n\n"
			result_text += "Margin: %.3f s\n\n" % (opponent_finish_real_time - player_finish_real_time)
		else:
			result_text = "YOU LOSE!\n\n"
			result_text += "Margin: %.3f s\n\n" % (player_finish_real_time - opponent_finish_real_time)

		result_text += "Your ET: %.3f s\n" % player_finish_time
		result_text += "Your Reaction: %.3f s\n\n" % player_reaction_time
		result_text += "Opponent ET: %.3f s\n" % opponent_finish_time
		result_text += "Opponent Reaction: %.3f s" % opponent_reaction_time

	results_label.text = result_text

func _on_restart_button_pressed():
	get_tree().reload_current_scene()

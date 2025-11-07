extends Node3D

@export var total_laps := 3
@export var checkpoint_count := 4

var current_lap := 1
var checkpoints_passed := 0
var lap_start_time := 0.0
var current_lap_time := 0.0
var best_lap_time := 0.0

var ui: Control

func _ready():
	lap_start_time = Time.get_ticks_msec() / 1000.0
	ui = get_node("/root/Main/UI")
	if ui:
		ui.update_lap(current_lap, total_laps)
		ui.update_best_time(0.0)

func _process(_delta):
	if current_lap <= total_laps:
		current_lap_time = (Time.get_ticks_msec() / 1000.0) - lap_start_time
		if ui:
			ui.update_time(current_lap_time)

func checkpoint_passed(checkpoint_id: int):
	if checkpoint_id == checkpoints_passed:
		checkpoints_passed += 1

		# Check if lap completed
		if checkpoints_passed >= checkpoint_count:
			complete_lap()

func complete_lap():
	var lap_time = current_lap_time

	# Update best time
	if best_lap_time == 0.0 or lap_time < best_lap_time:
		best_lap_time = lap_time
		if ui:
			ui.update_best_time(best_lap_time)

	# Move to next lap
	current_lap += 1
	checkpoints_passed = 0
	lap_start_time = Time.get_ticks_msec() / 1000.0

	if ui:
		ui.update_lap(current_lap, total_laps)

	if current_lap > total_laps:
		race_finished()

func race_finished():
	print("Race finished! Best lap: ", best_lap_time)

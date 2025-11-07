extends Control

@onready var speed_label = $SpeedContainer/SpeedLabel
@onready var lap_label = $LapContainer/LapLabel
@onready var time_label = $LapContainer/TimeLabel
@onready var best_time_label = $LapContainer/BestTimeLabel

var car: VehicleBody3D

func _ready():
	# Find the car in the scene
	car = get_tree().get_first_node_in_group("player_car")
	if not car:
		car = get_node("/root/Main/Car")

func _process(_delta):
	if car and car.has_method("get_speed_kmh") and speed_label:
		var speed = car.get_speed_kmh()
		speed_label.text = str(int(speed))

func update_lap(current_lap: int, total_laps: int):
	if lap_label:
		lap_label.text = "Lap: %d/%d" % [current_lap, total_laps]

func update_time(time: float):
	if time_label:
		var minutes = int(time) / 60
		var seconds = int(time) % 60
		var milliseconds = int((time - int(time)) * 100)
		time_label.text = "Time: %02d:%02d.%02d" % [minutes, seconds, milliseconds]

func update_best_time(time: float):
	if best_time_label:
		if time > 0:
			var minutes = int(time) / 60
			var seconds = int(time) % 60
			var milliseconds = int((time - int(time)) * 100)
			best_time_label.text = "Best: %02d:%02d.%02d" % [minutes, seconds, milliseconds]
		else:
			best_time_label.text = "Best: --:--.--"

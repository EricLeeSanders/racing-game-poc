extends VehicleBody3D

# Car properties
@export var max_engine_force := 2000.0
@export var max_brake_force := 100.0
@export var max_steering_angle := 0.5

# Input values
var steering_input := 0.0
var throttle_input := 0.0
var brake_input := 0.0

# Speed tracking
var current_speed := 0.0

func _ready():
	# Set initial center of mass lower for better stability
	center_of_mass_mode = CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = Vector3(0, -0.5, 0)

func _process(_delta):
	# Calculate current speed in km/h
	current_speed = linear_velocity.length() * 3.6

func _physics_process(delta):
	# Get input
	steering_input = Input.get_axis("ui_right", "ui_left")
	throttle_input = Input.get_action_strength("ui_up")
	brake_input = Input.get_action_strength("ui_down")

	# Apply steering
	steering = lerp(steering, steering_input * max_steering_angle, 5.0 * delta)

	# Apply throttle
	if throttle_input > 0:
		engine_force = throttle_input * max_engine_force
		brake = 0.0
	elif brake_input > 0:
		engine_force = 0.0
		brake = brake_input * max_brake_force
	else:
		# Coast to stop
		engine_force = 0.0
		brake = 5.0

func get_speed_kmh() -> float:
	return current_speed

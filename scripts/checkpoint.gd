extends Area3D

@export var checkpoint_id := 0

var lap_manager: Node3D

func _ready():
	lap_manager = get_node("/root/Main/LapManager")

func _on_body_entered(body):
	if body.name == "Car" and lap_manager:
		lap_manager.checkpoint_passed(checkpoint_id)

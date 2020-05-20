extends KinematicBody


onready var spr_body = $SprBody

var move_speed: float = 1.5 # Pixels per second.

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	var input_dir = Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0,
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	)
	
	if input_dir.length() > 1:
		input_dir = input_dir.normalized()
	
	if input_dir.length() > 0:
		spr_body.animation = "running"
		spr_body.flip_h = input_dir.x > 0
	else:
		spr_body.animation = "iddle"
		
	
	move_and_slide(input_dir * move_speed)

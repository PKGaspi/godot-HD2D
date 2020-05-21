extends CharacterState


var max_speed := 1.5
var move_speed := 1.4
var gravity := Vector3(0, -9.8, 0)
var jump_impulse := Vector3(0, 4, 0)

var velocity := Vector3.ZERO
var snap_length: float = 5



func input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if velocity.y < 1: velocity.y = 0 # Avoid extra momentum on slopes.
		_state_machine.transition_to("Move/Air", {velocity = velocity, jump_impulse = jump_impulse})


func physics_process(delta: float) -> void:
	var input_dir := get_input_dir()
	
	if input_dir.length() > 1:
		input_dir = input_dir.normalized()
	
	
	velocity = calculate_velocity(input_dir, delta)
	var snap := -character.get_floor_normal().normalized() * snap_length
	character.move_and_slide_with_snap(velocity, snap, Vector3.UP, true)
	


static func get_input_dir() -> Vector3:
	var input_dir := Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0,
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	)
	
	if input_dir.length() > 1:
		input_dir = input_dir.normalized()
	
	return input_dir

func calculate_velocity(movement_dir: Vector3, delta: float) -> Vector3:
	var new_velocity = movement_dir * move_speed
	new_velocity.y = velocity.y
	return new_velocity

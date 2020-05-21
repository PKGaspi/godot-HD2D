extends CharacterState

var old_snap_length: float

func enter(msg: Dictionary = {}) -> void:
	match msg:
		{"velocity": var v, "jump_impulse": var ji}:
			_parent.velocity = v + ji
	spr.animation = "jump"
	old_snap_length = _parent.snap_length
	_parent.snap_length = 0
	_parent.enter()


func exit() -> void:
	_parent.velocity.y = 0
	_parent.snap_length = old_snap_length
	_parent.exit()


func input(event: InputEvent) -> void:
	if event.is_action_released("jump"):
		_parent.velocity.y = min(_parent.velocity.y / 3, _parent.velocity.y)


func physics_process(delta: float) -> void:
	_parent.physics_process(delta)
	
	
	if character.is_on_floor():
		_state_machine.transition_to("Move/Iddle")
	elif character.is_on_ceiling():
		_parent.velocity.y = 0 #Bonck.

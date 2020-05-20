extends CharacterState


func enter(msg: Dictionary = {}) -> void:
	match msg:
		{"velocity": var v, "jump_impulse": var ji}:
			_parent.velocity = v + ji
	spr.animation = "jump"
	_parent.enter()


func exit() -> void:
	_parent.exit()


func physics_process(delta: float) -> void:
	_parent.physics_process(delta)
	
	if character.is_on_floor():
		_state_machine.transition_to("Move/Iddle")
	elif character.is_on_ceiling():
		_parent.velocity.y = 0 #Bonck.

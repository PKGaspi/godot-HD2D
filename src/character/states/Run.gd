extends CharacterState


func enter(msg: Dictionary = {}) -> void:
	spr.animation = "run"
	_parent.enter()


func exit() -> void:
	_parent.exit()


func input(event: InputEvent) -> void:
	_parent.input(event)


func physics_process(delta: float) -> void:
	_parent.physics_process(delta)
	
	var velocity = _parent.velocity
	if abs(velocity.x) > .01:
		spr.flip_h = _parent.velocity.x > .01
	
	if character.is_on_floor() or character.is_on_wall():
		if _parent.velocity.length() < .1:
			_state_machine.transition_to("Move/Iddle")
	else:
		_state_machine.transition_to("Move/Air")

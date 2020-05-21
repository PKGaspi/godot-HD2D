extends CharacterState


func enter(msg: Dictionary = {}) -> void:
	spr.animation = "iddle"
	_parent.enter()


func exit() -> void:
	_parent.exit()


func input(event: InputEvent) -> void:
	_parent.input(event)


func physics_process(delta: float) -> void:
	_parent.physics_process(delta)
	
	
	if character.is_on_floor():
		if _parent.velocity.length() > .01:
			_state_machine.transition_to("Move/Run")
	else:
		_state_machine.transition_to("Move/Air")

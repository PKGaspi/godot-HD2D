class_name StateMachine
extends Node

signal state_changed(current_state)


export var initial_state: NodePath

var current_state: State
var active = false setget set_active


func _ready() -> void:
	if not initial_state:
		initial_state = get_child(0).get_path()
	initialize(initial_state)


func initialize(initial_state: NodePath) -> void:
	set_active(true)
	current_state = get_node(initial_state)
	current_state.enter()


func set_active(value: bool) -> void:
	active = value
	set_physics_process(value)
	set_process_input(value)



func _input(event: InputEvent) -> void:
	current_state.input(event)


func _physics_process(delta: float) -> void:
	current_state.physics_process(delta)


func _change_state(state_path: NodePath, msg: Dictionary = {}) -> void:
	current_state.exit()
	
	current_state = get_node(initial_state)
	emit_signal("state_changed", current_state)
	
	current_state.enter(msg)
	

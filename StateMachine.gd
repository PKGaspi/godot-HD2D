class_name StateMachine
extends Node

signal state_changed(current_state)


export var initial_state: NodePath
export var initial_msg: Dictionary = {}

var current_state: State
var active = false setget set_active



func _init() -> void:
	add_to_group("state_machine")


func _ready() -> void:
	yield(owner, "ready")
	if not initial_state:
		initial_state = get_child(0).get_path()
	initialize(initial_state, initial_msg)


func initialize(initial_state: NodePath, initial_msg: Dictionary = {}) -> void:
	set_active(true)
	current_state = get_node(initial_state)
	current_state.enter(initial_msg)


func set_active(value: bool) -> void:
	active = value
	set_physics_process(value)
	set_process_input(value)



func _input(event: InputEvent) -> void:
	current_state.input(event)


func _physics_process(delta: float) -> void:
	current_state.physics_process(delta)


func transition_to(state_path: NodePath, msg: Dictionary = {}) -> void:
	current_state.exit()
	
	current_state = get_node(state_path)
	emit_signal("state_changed", current_state)
	
	current_state.enter(msg)
	

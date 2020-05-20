class_name CharacterState
extends State

var character: KinematicBody
var spr: AnimatedSprite3D


func _ready() -> void:
	yield(owner, "ready")
	character = owner
	spr = character.spr

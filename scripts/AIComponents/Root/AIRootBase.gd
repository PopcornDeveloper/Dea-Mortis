extends CharacterBody3D

class_name AIRoot

@export var target : CharacterBody3D

func _ready() -> void:
	if not target:
		target = get_tree().get_first_node_in_group("player")

func _update():
	move_and_slide()

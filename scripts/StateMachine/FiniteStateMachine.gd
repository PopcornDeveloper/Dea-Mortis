extends Node
class_name FiniteStateMachine

@export var STATES : Dictionary
var current_state : Node

func _ready():
	for i in get_children():
		STATES[i.name] = i
	current_state = STATES["IDLE"]

func change_state(old_state, new_state):
	old_state.exit()
	current_state = STATES[new_state.name]
	new_state.enter()
	current_state = new_state

func _update(delta):
	current_state.update(delta)

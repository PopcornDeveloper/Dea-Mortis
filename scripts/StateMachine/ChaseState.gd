extends State
class_name ChaseState

@onready var ChaseOptimRand = randi_range(20,60)
@onready var ChaseOptimDelta = 0

@export var NavigationAgent : MeleeNavigationAgent
@onready var target : CharacterBody3D = get_parent().get_parent().target
func enter():
	pass
func exit():
	pass
func update(_delta) -> void:
	ChaseOptimDelta += 1
	if ChaseOptimDelta >= ChaseOptimDelta:
		NavigationAgent.set_movement_target(target.global_position)
		ChaseOptimDelta = 0

extends NavigationAgent3D
class_name MeleeNavigationAgent

@export var navigation_agent : NavigationAgent3D
@export var state_machine : FiniteStateMachine

@export var target : Node3D

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = get_parent().global_position.direction_to(next_path_position) * 5
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	get_parent().velocity = safe_velocity
	get_parent().move_and_slide()

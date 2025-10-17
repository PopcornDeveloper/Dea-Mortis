extends CharacterBody3D
class_name MeleeNavigationEnemy

@export var navigation_agent : NavigationAgent3D
@export var health = 50
@export var max_health = 50

var OptimDelta : int = 0
var OptimDeltaRand : int = randi_range(20,60)

enum STATES {
	IDLE,
	CHASE,
	CIRC_IN, 
}
var current_state = STATES.CHASE
@export var target : Node3D

func take_damage(damage):
	health -= damage
	if health <= 0:
		queue_free()

func _process(delta: float) -> void:
	handle_states()

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * 5
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()


func handle_states():
	match current_state:
		STATES.IDLE:
			pass
		STATES.CHASE:
			OptimDelta += 1
			if OptimDelta >= OptimDeltaRand:
				set_movement_target(target.global_position)
				OptimDelta = 0

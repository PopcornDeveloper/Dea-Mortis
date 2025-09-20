extends CharacterBody3D
class_name MeleeNavigationEnemy

@export var navigation_agent : NavigationAgent3D

@onready var other_enemies = get_tree().get_nodes_in_group("enemy_melee") ## so the enemies dont get stuck lol

var health = 50
var max_health = 50

var OptimDelta : float = 0.0
var OptimDeltaRand : float = randf()

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

func GetClosestEnemyDistance(globalvector : Vector3):
	var dist_array = []
	for i in other_enemies:
		if i and i != self:
			dist_array.append(i.global_position.distance_to(globalvector))
	
	
	var TrueCool = 0.0 # i did not have any name ideas sorry
	for i in dist_array:
		if i < TrueCool:
			TrueCool = i
	
	return TrueCool


func handle_states():
	match current_state:
		STATES.IDLE:
			pass
		STATES.CHASE:
			if target and navigation_agent.is_navigation_finished():
				OptimDelta += get_process_delta_time()
				if OptimDelta >= OptimDeltaRand:
					if target.global_position.distance_to(global_position) > 10 and GetClosestEnemyDistance(target.global_position) > 10:
						set_movement_target(target.global_position + Vector3(randf_range(-100,100),0,randf_range(-100,100)))
					else:
						set_movement_target(target.global_position)

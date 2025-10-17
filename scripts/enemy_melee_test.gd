extends MeleeNavigationEnemy
class_name MeleeEnemyBase

## TODO : Enemy model and animations

@export var hit_box : ShapeCast3D

func _process(delta: float) -> void:
	super.handle_states()

func attack(damage):
	## Put animation logic in here

	hit_box.force_shapecast_update()
	if hit_box.is_colliding():
		for i in hit_box.get_collision_count():
			for v in hit_box.get_collider(i):
				if v.is_in_group("damage"):
					v.take_damage(damage)

func _physics_process(delta):
	super._physics_process(delta)

	look_at(target.global_position)
	global_rotation.z = 0
	global_rotation.x = 0

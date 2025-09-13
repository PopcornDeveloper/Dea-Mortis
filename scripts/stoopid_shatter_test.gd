extends CharacterBody3D

@onready var BodyCollection = get_parent().get_child(1)

func _ready() -> void:
	for i in BodyCollection.get_children():
		if i is RigidBody3D:
			i.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
			i.freeze = true

func take_damage(damage):
	for i in BodyCollection.get_children():
		if i is RigidBody3D:
			i.freeze = false
			i.apply_force(self.global_position + i.global_position * 500)
			queue_free()

extends Node3D

var can_attack = true

var megathrusting = false ## i know, stupid name, right?

@export var shape_cast : ShapeCast3D

@export var head : Node3D
@export var camera : Camera3D
@export var player : CharacterBody3D

@export var swing_sound : AudioStreamPlayer3D
@export var cast : RayCast3D
@export var animation_player : AnimationPlayer

@export var damage_cut = 100.0
@export var damage_MEGAthrust = 5
@export var damage_thrust = 150.0

@export var cut_speed = 0.105
@export var thrust_speed = 0.2
@export var MEGAthrust_speed = 0.35

@export var cut_cooldown = 0.5
@export var thrust_cooldown = 0.25

@export var thrust_range = 2.0
@export var cut_range = 1.0

## For all attacks : Make hit particles (USING RAYCAST3D)

func MegaThrust(): ##Specil Ability
	swing_sound.pitch_scale = randf_range(0.7, 1.3)
	swing_sound.volume_db = randf_range(4, 6)
	swing_sound.play()
	
	cast.target_position = Vector3(0,0,-1.5)
	
	animation_player.stop()
	animation_player.play("MegaThrust")

	can_attack = false

	await get_tree().create_timer(MEGAthrust_speed).timeout
	megathrusting = true

	camera.apply_shake(0.05)
	
	if shape_cast.is_colliding():
		for i in shape_cast.get_collision_count():
			var coll = shape_cast.get_collider(i)
			if coll.is_in_group("damage") and not coll is Player:
				coll.take_damage(200)	
	
	if player.is_on_floor():
		player.velocity += -player.transform.basis.z * 30
	else:
		print(90.0 + head.rotation_degrees.x)
		if 90.0 + head.rotation_degrees.x > 5.0:
			player.velocity.y += -head.transform.basis.z.y * 10
			player.velocity.x += -player.transform.basis.z.x * 10
			player.velocity.z += -player.transform.basis.z.z * 10
		else:
			player.velocity.y += -head.transform.basis.z.y * 40
	
	
	await get_tree().create_timer(0.9 - 0.35).timeout
	megathrusting = false
	can_attack = true


func cut():
	swing_sound.pitch_scale = randf_range(0.7, 1.3)
	swing_sound.volume_db = randf_range(4, 6)
	swing_sound.play()

	animation_player.play("cut")
	can_attack = false

	await get_tree().create_timer(cut_speed).timeout

	
	if shape_cast.is_colliding():
		for i in shape_cast.get_collision_count():
			var coll = shape_cast.get_collider(i)
			if coll.is_in_group("damage") and not coll is Player:
				coll.take_damage(damage_cut) 
			print(coll)
	
	## TODO use raycast for FX (Blood, Hit particles)
	await get_tree().create_timer(cut_cooldown).timeout
	can_attack = true

func thrust():
	swing_sound.pitch_scale = randf_range(0.7, 1.3)
	swing_sound.volume_db = randf_range(4, 6)
	swing_sound.play()
	
	animation_player.play("thrust")
	can_attack = false

	await get_tree().create_timer(thrust_speed).timeout
	
	if shape_cast.is_colliding():
		for i in shape_cast.get_collision_count():
			var coll = shape_cast.get_collider(i)
			if coll.is_in_group("damage") and not coll is Player:
				coll.take_damage(damage_thrust)
	
	await get_tree().create_timer(cut_cooldown).timeout
	can_attack = true

func _process(delta: float) -> void:
	if megathrusting:
		if shape_cast.is_colliding():
			for i in shape_cast.get_collision_count():
				var collider = shape_cast.get_collider(i)
				if collider and collider.is_in_group("damage") and not collider is Player:
					collider.take_damage(player.velocity.length() * damage_MEGAthrust)
	if can_attack:
		if Input.is_action_just_pressed("main_cut"):
			cut()
		elif Input.is_action_just_pressed("main_thrust"):
			thrust()
		elif Input.is_action_just_pressed("SpecialOne"):
			MegaThrust()

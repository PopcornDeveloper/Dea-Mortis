extends Node3D

var can_attack = true

var megathrusting = false ## i know, stupid name, right?

@export var head : Node3D
@export var camera : Camera3D
@export var player : CharacterBody3D

@export var swing_sound : AudioStreamPlayer3D
@export var cast : RayCast3D
@export var animation_player : AnimationPlayer

@export var damage_cut = 10.0
@export var damage_MEGAthrust = 5
@export var damage_thrust = 40.0

@export var cut_speed = 0.25
@export var thrust_speed = 0.2
@export var MEGAthrust_speed = 0.45

@export var cut_cooldown = 0.25
@export var thrust_cooldown = 0.25

@export var thrust_range = 2.0
@export var cut_range = 1.0

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
	if cast.is_colliding():
		var collider = cast.get_collider()
		if collider.is_in_group("damage"):
			collider.take_damage(damage_MEGAthrust)
	if player.is_on_floor():
		player.velocity += -player.transform.basis.z * 30
	else:
		print(90.0 + head.rotation_degrees.x)
		if 90.0 + head.rotation_degrees.x > 5.0:
			player.velocity.y += -head.transform.basis.z.y * 20
			player.velocity.x += -player.transform.basis.z.x * 10
			player.velocity.z += -player.transform.basis.z.z * 10
		else:
			player.velocity.y += -head.transform.basis.z.y * 40
	
	
	await get_tree().create_timer(cut_cooldown).timeout
	megathrusting = false
	can_attack = true


func cut():
	swing_sound.pitch_scale = randf_range(0.7, 1.3)
	swing_sound.volume_db = randf_range(4, 6)
	swing_sound.play()
	
	cast.target_position = Vector3(0,0,-thrust_range)

	animation_player.play("cut")
	can_attack = false

	await get_tree().create_timer(cut_speed).timeout
	if cast.is_colliding():
		var collider = cast.get_collider()
		if collider.is_in_group("damage"): 
			collider.take_damage(damage_cut)
		if collider is RigidBody3D:
			collider.apply_impulse((-transform.basis.z + -collider.transform.basis.z))
	await get_tree().create_timer(cut_cooldown).timeout
	can_attack = true

func thrust():
	swing_sound.pitch_scale = randf_range(0.7, 1.3)
	swing_sound.volume_db = randf_range(4, 6)
	swing_sound.play()
	
	cast.target_position = Vector3(0,0,-thrust_range)
	
	animation_player.play("thrust")
	can_attack = false

	await get_tree().create_timer(thrust_speed).timeout
	if cast.is_colliding():
		var collider = cast.get_collider()
		if collider.is_in_group("damage"):
			collider.take_damage(damage_thrust)
	
	await get_tree().create_timer(cut_cooldown).timeout
	can_attack = true

func _process(delta: float) -> void:
	if megathrusting:
		cast.force_raycast_update()
		if cast.is_colliding():
			var collider = cast.get_collider()
			if collider.is_in_group("damage"):
				collider.take_damage(damage_MEGAthrust * player.velocity.length())
	if can_attack:
		if Input.is_action_just_pressed("main_cut"):
			cut()
		elif Input.is_action_just_pressed("main_thrust"):
			thrust()
		elif Input.is_action_just_pressed("SpecialOne"):
			MegaThrust()

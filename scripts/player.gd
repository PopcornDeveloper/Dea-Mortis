class_name Player
extends CharacterBody3D


@export var fall_detect_cast : ShapeCast3D
var mouse_mov = Vector2(0,0)

@export var rockburst : PackedScene
var direction : Vector3

var speed : float = 6.5
var accel : float = 40.0
var friction : float = 50.0

var sensitivity := 0.25

@export var swoosh_particles : Node3D
@export var head : Node3D

var move_amounts : Array

func _ready() -> void:
	for i in swoosh_particles.get_children():
		if i is MeshInstance3D:
			move_amounts.append(randf_range(-10,10))
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		mouse_mov = -event.relative * 60 * get_process_delta_time()

var superjump_meter := 0.0

func _process(delta: float) -> void:
	print(velocity)
	if Input.is_action_just_pressed("enable_mouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	
	swoosh_particles.scale = lerp(swoosh_particles.scale, Vector3(0.005,0.005,0.005), 5 * delta)

	swoosh_particles.get_child(0).material_override.albedo_color.a = lerpf(swoosh_particles.get_child(0).material_override.albedo_color.a, 0, 10 * delta) 
	
	for i : MeshInstance3D in swoosh_particles.get_children():
		i.rotate_y(move_amounts[i.get_index()] * delta)	

	if fall_detect_cast.is_colliding() and velocity.y <= -10:
		$Crack.volume_db = -37 + -velocity.y / 50 + randf_range(-0.5,0.5)
		var new : GPUParticles3D = rockburst.instantiate()
		
		get_tree().get_root().add_child(new)
		new.global_position = fall_detect_cast.global_position
		new.restart()

		if not $Crack.playing:
			$Crack.play()
		$Head/Camera3D.apply_shake(-velocity.y / 70)
		for i in fall_detect_cast.get_collision_count():
			var collider = fall_detect_cast.get_collider(i)
			if collider and collider.is_in_group("damage"):
				collider.take_damage(-velocity.y * 2)
	$CanvasLayer/Control/ColorRect.scale.x = superjump_meter * 2
	if not Input.is_action_pressed("crouch"):
		superjump_meter = lerpf(superjump_meter, 0.0, 10 * delta)
	
	mouse_mov = lerp(mouse_mov, Vector2.ZERO, 10 * delta)
	
	
	direction = Vector3.ZERO
	if Input.is_action_pressed("forward"):
		direction.z -= 1.0
	if Input.is_action_pressed("backward"):
		direction.z += 1.0
	if Input.is_action_pressed("left"):
		direction.x -= 1.0
	if Input.is_action_pressed("right"):
		direction.x += 1.0
	# Currently, the vector's length is greater than 1 while trying to move diagonally
	# This means the player moves faster in diagonals than when going in cardinal directions
	# (which is not very good)
	# Normalizing the vector ensures the length will always be 1, and the movement speed
	# will be the same regardless of if the player is moving diagonally or not
	direction = direction.normalized()

	# Because we aren't using the transforms for the direction anymore, we need to rotate
	# the vector using our yaw so movement is aligned with it
	direction = direction.rotated(Vector3(0, 1, 0), rotation.y)
	head.rotation_degrees = Vector3(head.rotation_degrees.x + sensitivity * mouse_mov.y, 0, 0)
	rotation_degrees = Vector3(0, self.rotation_degrees.y + sensitivity * mouse_mov.x, 0)

	head.rotation_degrees.x = clampf(head.rotation_degrees.x, -89.9, 89.9)
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = 5.0
		if Input.is_action_pressed("crouch"):
			$CollisionShape3D.shape.height = lerpf($CollisionShape3D.shape.height, 1.0, 10 * delta)
			head.position.y = lerpf(head.position.y, -0.137, 10 * delta)

			superjump_meter += delta
			
			superjump_meter = clampf(superjump_meter,-0.01, 0.5)
			if superjump_meter >= 0.5:
				if Input.is_action_just_pressed("jump"):
					velocity.y = superjump_meter * 50
					velocity += -transform.basis.z * 1
					superjump_meter = 0.0
		else:
			$CollisionShape3D.shape.height = lerpf($CollisionShape3D.shape.height, 2.0, 10 * delta)
			head.position.y = lerpf(head.position.y, 0.363, 10 * delta)

		if not direction.is_zero_approx():
			if Input.is_action_pressed("crouch"):
				velocity = velocity.move_toward(Vector3(direction.x * speed / 3, velocity.y, direction.z * speed / 3), friction * delta)
			else:
				velocity = velocity.move_toward(Vector3(direction.x * speed, velocity.y, direction.z * speed), friction * delta)
		else:
			velocity = velocity.move_toward(Vector3(0, velocity.y, 0), friction * delta)
	else:
		velocity.y -= 15.34 * delta #15.34
		if not direction.is_zero_approx():
			velocity = velocity.move_toward(Vector3(direction.x * speed, velocity.y, direction.z * speed), friction * delta)

func _physics_process(delta: float) -> void:
	$"CanvasLayer/FPSLabel".text = "fps : " + str(Engine.get_frames_per_second()) + " | speed : " + str(velocity.length())

	
	move_and_slide()

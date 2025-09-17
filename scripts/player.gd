class_name Player
extends CharacterBody3D


@export var fall_detect_cast : ShapeCast3D
var mouse_mov = Vector2(0,0)

@export var rockburst : PackedScene
var direction : Vector3

var speed : float = 6.5
var accel : float = 40.0
var friction : float = 20.0

var sensitivity := 0.25

@export var swoosh_particles : GPUParticles3D
@export var head : Node3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		mouse_mov = -event.relative * 60 * get_process_delta_time()

var superjump_meter := 0.0

func _process(delta: float) -> void:
	if velocity.y < -10.0 and velocity.y < 0.0:
		swoosh_particles.position.y = -0.5
	else:
		swoosh_particles.look_at(velocity * 300)
	if velocity.length() > 10.0 or (velocity.y < -10.0 and velocity.y < 0.0):
	
		swoosh_particles.emitting = true
	else:
		swoosh_particles.emitting = false
	
	
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
		direction -= transform.basis.z
	if Input.is_action_pressed("backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("right"):
		direction += transform.basis.x
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
				velocity.x = move_toward(velocity.x, direction.x * speed / 3, accel * delta)
				velocity.z = move_toward(velocity.z, direction.z * speed / 3, accel * delta)
			else:
				velocity.x = move_toward(velocity.x, direction.x * speed, accel * delta)
				velocity.z = move_toward(velocity.z, direction.z * speed, accel * delta)
		else:
			velocity.x = move_toward(velocity.x, direction.x * speed, friction * delta)
			velocity.z = move_toward(velocity.z, direction.z * speed, friction * delta)
	else:
		velocity.y -= 15.34 * delta
		if not direction.is_zero_approx():
			velocity.x = move_toward(velocity.x, direction.x * speed / 3, accel * delta)
			velocity.z = move_toward(velocity.z, direction.z * speed / 3, accel * delta)

func _physics_process(delta: float) -> void:
	$"CanvasLayer/FPSLabel".text = "fps : " + str(Engine.get_frames_per_second()) + " | speed : " + str(velocity.length())

	
	move_and_slide()

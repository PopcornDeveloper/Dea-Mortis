extends Node3D

var mouse_mov : Vector2

func _input(event: InputEvent) -> void: 
	if event is InputEventMouseMotion:
		mouse_mov = event.relative

func _process(delta: float) -> void:
	mouse_mov.lerp(Vector2.ZERO, 10 * delta)

	var movtween = create_tween()
	movtween.tween_property(self, "rotation_degrees", Vector3(mouse_mov.y / 5, mouse_mov.x / 5, 0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

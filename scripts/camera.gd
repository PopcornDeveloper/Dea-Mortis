extends Camera3D

@export var randomStrength: float = 30.0
@export var shakeFade: float = 5.0

var rng = RandomNumberGenerator.new()

var shake_strength: float = 0.0

func apply_shake(strength):
	shake_strength = strength

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakeFade * delta)

		h_offset = randomOffset().x
		v_offset = randomOffset().y
		get_child(0).position.x = h_offset
		get_child(0).position.y = v_offset

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength,shake_strength),rng.randf_range(-shake_strength,shake_strength))

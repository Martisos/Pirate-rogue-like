extends CharacterBody2D

const speed = 200.0
const turn_speed = 3.0

var target: Vector2

func _ready() -> void:
	target = global_position

func _input(event) -> void:
	if event.is_action_pressed("click"):
		target = get_global_mouse_position()

func _physics_process(delta: float) -> void:
	if position.distance_to(target) > 10:
		var direction_to_target = global_position.direction_to(target)
		var target_angle = direction_to_target.angle()
		
		rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
		
		velocity = Vector2.RIGHT.rotated(rotation) * speed
		
		move_and_slide()
	else:
		velocity = Vector2.ZERO

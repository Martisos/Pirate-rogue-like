extends CharacterBody2D

const speed = 200.0
const turn_speed = 3.0

@export var cannonball_scene : PackedScene = preload("uid://c3c8elea3mokb")

@onready var left_cannon: Marker2D = $LeftCannon
@onready var right_cannon: Marker2D = $RightCannon


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


func _on_shoot_timer_timeout() -> void:
	if cannonball_scene != null:
		var ball_left = cannonball_scene.instantiate()
		get_tree().root.add_child(ball_left)
		ball_left.global_position = left_cannon.global_position
		ball_left.rotation = rotation - (PI / 2.0) #why radians are in godot brooooo
		
		var ball_right = cannonball_scene.instantiate()
		get_tree().root.add_child(ball_right)
		ball_right.global_position = right_cannon.global_position
		ball_right.rotation = rotation + (PI / 2.0) #why radians are still in godot brooooo

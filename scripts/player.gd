extends CharacterBody2D

var speed = 250.0
var turn_speed = 4.0


@export var cannonball_scene: PackedScene = preload("uid://c3c8elea3mokb")
@onready var level_up_ui: CanvasLayer = $"../LevelUpUI"
@onready var shoot_timer: Timer = $ShootTimer

@onready var label_health: Label = $Stats/Health
@onready var label_speed: Label = $Stats/Speed
@onready var label_damage: Label = $Stats/Damage
@onready var label_attack_speed: Label = $Stats/AttackSpeed
@onready var label_next_level: Label = $Stats/NextLevel


@onready var left_cannon: Marker2D = $LeftCannon
@onready var right_cannon: Marker2D = $RightCannon

var max_health: int = 3
var health: int = 3

var shoot_cooldown: float = 1.0
var bonus_damage: int = 0

var level: int = 1
var current_exp: float = 0.0
var exp_to_new_level: float = 5.0

var target: Vector2


func _ready() -> void:
	target = global_position
	shoot_timer.wait_time = shoot_cooldown
	shoot_timer.start()

func _input(event) -> void:
	if event.is_action_pressed("click"):
		target = get_global_mouse_position()

func _physics_process(delta: float) -> void:
	
	if position.distance_to(target) < 20:
		velocity = Vector2.ZERO
	
	if position.distance_to(target) > 20:
		var direction_to_target = global_position.direction_to(target)
		var target_angle = direction_to_target.angle()
		
		rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
		
		velocity = Vector2.RIGHT.rotated(rotation) * speed
		
		move_and_slide()
	else:
		velocity = Vector2.ZERO
	
	_update_stats_display()

func _update_stats_display() -> void:
	label_health.text = "HP: " + str(health) + "/" + str(max_health)
	label_speed.text = "Speed: " + str(speed)
	label_damage.text = "Damage: " + str(1 + bonus_damage)
	label_attack_speed.text = "Attack Speed: " + str(shoot_cooldown)
	label_next_level.text = "To next level: " + str(exp_to_new_level - current_exp)


func _on_shoot_timer_timeout() -> void:
	
	shoot_timer.wait_time = shoot_cooldown
	
	if cannonball_scene != null:
		var ball_left = cannonball_scene.instantiate()
		ball_left.shooter = self
		get_tree().root.add_child(ball_left)
		ball_left.global_position = left_cannon.global_position
		ball_left.rotation = rotation - (PI / 2.0) #why radians are in godot brooooo
		ball_left.damage += bonus_damage
		
		var ball_right = cannonball_scene.instantiate()
		ball_right.shooter = self
		get_tree().root.add_child(ball_right)
		ball_right.global_position = right_cannon.global_position
		ball_right.rotation = rotation + (PI / 2.0) #why radians are still in godot brooooo
		ball_right.damage += bonus_damage

func gain_exp(amount: int):
	current_exp += amount
	if current_exp >= exp_to_new_level:
		level_up()


func level_up():
	level += 1
	current_exp -= exp_to_new_level
	exp_to_new_level = int(exp_to_new_level * 1.4)
	print("level up: ", level)
	if level_up_ui != null:
		level_up_ui.show_upgrades()

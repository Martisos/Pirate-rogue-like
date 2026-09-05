extends CharacterBody2D

signal health_changed_signal(current_health, max_health)
signal exp_changed_signal(current_exp, exp_to_new_level)
signal level_up_signal(new_level)

var speed: float = 250.0
var turn_speed: float = 2.0
var can_move: bool = true

@export var cannonball_scene: PackedScene = preload("uid://c3c8elea3mokb")
@onready var level_up_ui: CanvasLayer = $"../LevelUpUI"
@onready var shoot_timer: Timer = $ShootTimer

@onready var label_health: Label = $Stats/Health
@onready var label_speed: Label = $Stats/Speed
@onready var label_damage: Label = $Stats/Damage
@onready var label_attack_speed: Label = $Stats/AttackSpeed
@onready var label_exp_to_level: Label = $Stats/Exp_to_level
@onready var label_next_level: Label = $Stats/NextLevel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var exp_magnet: Area2D = $ExpMagnet
@onready var direction: ColorRect = $"../Direction"
@onready var camera: Camera2D = $Camera2D
@onready var sprite: Sprite2D = $Sprite2D


@onready var left_cannon: Marker2D = $LeftCannon
@onready var right_cannon: Marker2D = $RightCannon

var max_health: int = 6
var health: int = 3

var shoot_cooldown: float = 0.2
var bonus_damage: int = 5

var camera_zoom: float = 0.7

var level: int = 1
var current_exp: int = 0
var exp_to_new_level: int = 1
var pending_level_ups: int = 0

var magnet_area_size: float = 1.0
var target: Vector2


func _ready() -> void:
	target = global_position
	shoot_timer.wait_time = shoot_cooldown
	shoot_timer.start()
	can_move = true

func _input(event) -> void:
	if event.is_action_pressed("click") and can_move:
		target = get_global_mouse_position()
		direction.global_position = target

func _physics_process(delta: float) -> void:
	
	if position.distance_to(target) < 50:
		velocity = Vector2.ZERO
	
	if position.distance_to(target) > 50:
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
	label_exp_to_level.text = "Exp to new level: " + str(exp_to_new_level)

func apply_unique_upgrades() -> void:
	exp_magnet.scale = Vector2(magnet_area_size, magnet_area_size) 
	camera.zoom = Vector2(camera_zoom, camera_zoom)

func take_damage(amount: int) -> void:
	health -= amount
	health_changed_signal.emit(health, max_health)
	
	camera.apply_screen_shake(12.5)
	apply_hit_flash()
	
	if health <= 0:
		die()

func apply_hit_flash() -> void:
	var tween = create_tween()
	
	sprite.modulate = Color(15.0, 15.0, 15.0)
	
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)

func die() -> void:
	#there will be something
	print("died, Your level: ", level)
	can_move = false
	speed = 0.0
	pass

func _on_shoot_timer_timeout() -> void:
	
	shoot_timer.wait_time = shoot_cooldown
	
	if !can_move:
		return
	
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
	print(current_exp, " ", amount)
	while current_exp >= exp_to_new_level:
		current_exp -= exp_to_new_level
		exp_to_new_level = int(exp_to_new_level * 1.4)
		level += 1
		pending_level_ups += 1
		print("level_ups in queue: ", pending_level_ups)
		
	exp_changed_signal.emit(current_exp, exp_to_new_level)
	
	if pending_level_ups > 0 and not get_tree().paused:
		process_next_level_up()

func process_next_level_up() -> void:
	if pending_level_ups > 0:
		pending_level_ups -= 1
		
		await get_tree().create_timer(0.2, true, false, true).timeout
		level_up_signal.emit(level)
		
		if level_up_ui != null:
			level_up_ui.show_upgrades()

func level_up():
	level += 1
	current_exp -= exp_to_new_level
	
	print("level up: ", level)
	
	level_up_signal.emit(level)
	exp_changed_signal.emit(current_exp, exp_to_new_level)
	
	if level_up_ui != null:
		level_up_ui.show_upgrades()

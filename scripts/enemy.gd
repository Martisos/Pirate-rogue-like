extends CharacterBody2D

@export var speed: float = 200.0
@export var max_health: int = 3
@export var attack_range: float = 600.0
@export var attack_cooldown: float = 2.0
@export var turn_speed: float = 2.0
@export var cannonball_scene : PackedScene = preload("uid://c3c8elea3mokb")
@export var exp_drop : PackedScene = preload("uid://c2cc2gctbtjcr")


var health: int
var player = null
var can_shoot: bool = true
var choosen_side: String = ""

@onready var shoot_cooldown: Timer = $ShootCooldown
@onready var cannons_node: Node2D = $Cannons


func _ready() -> void:
	health = max_health
	var playersGroup = get_tree().get_nodes_in_group("player")
	if playersGroup.size() > 0:
		player = playersGroup[0]

func _physics_process(delta: float) -> void:
	if not player:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	var target_direction = global_position.direction_to(player.global_position)
	var target_angle = target_direction.angle()
	
	if distance_to_player <= attack_range:
		if choosen_side == "":
			var enemy_forward = Vector2.RIGHT.rotated(rotation)
			var cross_product = enemy_forward.cross(target_direction)
			
			if cross_product < 0:
				choosen_side = "left"
			else:
				choosen_side = "right"
			
				
		if choosen_side == "left":
			target_angle += PI / 2.0
		else:
			target_angle -= PI / 2.0
	else:
		choosen_side = ""
		
	rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
	
	#attacks and movement
	if distance_to_player > attack_range:
		velocity = Vector2.RIGHT.rotated(rotation) * speed
		move_and_slide()
	else:
		
		velocity = Vector2.ZERO
		
		if can_shoot:
			shoot()

func shoot() -> void:
	if cannonball_scene != null and cannons_node != null:
		can_shoot = false
		
		var shot_left = (choosen_side == "left")
		
		for cannon in cannons_node.get_children():
			
			if cannon.name.begins_with("L") and shot_left:
				var ball = cannonball_scene.instantiate()
				ball.shooter = self
				get_tree().root.add_child(ball)
				ball.global_position = cannon.global_position
				ball.rotation = rotation - (PI / 2.0)
				
			elif cannon.name.begins_with("R") and not shot_left:
				var ball = cannonball_scene.instantiate()
				ball.shooter = self
				get_tree().root.add_child(ball)
				ball.global_position = cannon.global_position
				ball.rotation = rotation + (PI / 2.0)
				
			shoot_cooldown.start(attack_cooldown)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die():
	#fancy something after enemy dies
	if exp_drop != null:
		var drop = exp_drop.instantiate()
		get_tree().current_scene.call_deferred("add_child", drop)
		drop.global_position = global_position
	queue_free()

func _on_shoot_cooldown_timeout() -> void:
	can_shoot = true

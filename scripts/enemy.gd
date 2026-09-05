extends CharacterBody2D

@export var speed: float = 200.0
@export var max_health: int = 3
@export var attack_range: float = 600.0
@export var attack_cooldown: float = 2.0
@export var turn_speed: float = 2.0
@export var cannonball_scene : PackedScene = preload("uid://c3c8elea3mokb")
@export var exp_drop : PackedScene = preload("uid://c2cc2gctbtjcr")
@export var exp_amount : int = 1
@onready var sprite: Sprite2D = $Sprite2D

var health: int
var player = null
var can_shoot: bool = true
var choosen_side: String = ""

var has_middle_cannon: bool = false

@onready var shoot_cooldown: Timer = $ShootCooldown
@onready var cannons_node: Node2D = $Cannons
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	health = max_health
	nav_agent.max_speed = speed
	var playersGroup = get_tree().get_nodes_in_group("player")
	if playersGroup.size() > 0:
		player = playersGroup[0]
	nav_agent.velocity_computed.connect(_on_safe_velocity_computed)
	
	if cannons_node != null:
		for cannon in cannons_node.get_children():
			if cannon.name.begins_with("M"):
				has_middle_cannon = true
				break

func _physics_process(delta: float) -> void:
	if not player:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	var direction_to_player = global_position.direction_to(player.global_position)
	
	nav_agent.target_position = player.global_position
	var next_path_pos = nav_agent.get_next_path_position()
	var direction_to_path = global_position.direction_to(next_path_pos)
	
	
	var target_angle = 0.0
	
	if distance_to_player <= attack_range:
		target_angle = direction_to_player.angle()
		
		if not has_middle_cannon:
			if choosen_side == "":
				var enemy_forward = Vector2.RIGHT.rotated(rotation)
				var cross_product = enemy_forward.cross(direction_to_player)
				
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
		target_angle = direction_to_path.angle()
		
	rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
	
	var intended_velocity = Vector2.ZERO
	
	if distance_to_player > attack_range:
		
		var current_speed = speed * EnemyDebuffs.speed_debuff_multiplier
		nav_agent.max_speed = current_speed
		
		intended_velocity = direction_to_path * current_speed
	else:
		if can_shoot:
			shoot()
	
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(intended_velocity)
	else:
		_on_safe_velocity_computed(intended_velocity)

func _on_safe_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

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
				ball.speed = ball.speed * EnemyDebuffs.cannonball_speed_debuff_multiplier
				
			elif cannon.name.begins_with("R") and not shot_left:
				var ball = cannonball_scene.instantiate()
				ball.shooter = self
				get_tree().root.add_child(ball)
				ball.global_position = cannon.global_position
				ball.rotation = rotation + (PI / 2.0)
				ball.speed = ball.speed * EnemyDebuffs.cannonball_speed_debuff_multiplier
			
			elif cannon.name.begins_with("M"):
				var ball = cannonball_scene.instantiate()
				ball.shooter = self
				get_tree().root.add_child(ball)
				ball.global_position = cannon.global_position
				ball.rotation = rotation
				ball.speed = ball.speed * EnemyDebuffs.cannonball_speed_debuff_multiplier
			
		shoot_cooldown.start(attack_cooldown * EnemyDebuffs.attack_speed_debuff_multiplier)


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func apply_hit_flash() -> void:
	var tween = create_tween()
	
	sprite.modulate = Color(15.0, 15.0, 15.0)
	
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)


func die():
	#fancy something after enemy dies
	if exp_drop != null:
		var drop = exp_drop.instantiate()
		get_tree().current_scene.call_deferred("add_child", drop)
		drop.global_position = global_position
		drop.set_exp_amount(exp_amount)
	queue_free()

func _on_shoot_cooldown_timeout() -> void:
	can_shoot = true

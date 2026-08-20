extends CharacterBody2D

@export var speed: float = 200.0
@export var max_health: int = 3
@export var attack_range: float = 600.0
@export var attack_cooldown: float = 2.0
@export var cannonball_scene : PackedScene = preload("uid://c3c8elea3mokb")

var health: int
var player = null
var can_shoot: bool = true

@onready var cannon_point: Marker2D = $CannonPoint
@onready var shoot_cooldown: Timer = $ShootCooldown


func _ready() -> void:
	health = max_health
	var playersGroup = get_tree().get_nodes_in_group("player")
	if playersGroup.size() > 0:
		player = playersGroup[0]

func _physics_process(delta: float) -> void:
	if not player:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	look_at(player.global_position)
	
	#attacks and movement
	if distance_to_player > attack_range:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		
		if can_shoot:
			shoot()

func shoot() -> void:
	if cannonball_scene != null and cannon_point != null:
		can_shoot = false
		var ball = cannonball_scene.instantiate()
		get_tree().root.add_child(ball)
		
		ball.global_position = cannon_point.global_position
		ball.rotation = rotation
		
		shoot_cooldown.start(attack_cooldown)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die():
	#fancy something after enemy dies
	queue_free()


func _on_shoot_cooldown_timeout() -> void:
	can_shoot = true

extends Area2D

@export var damage: int = 1
@export var through_ships_ball: int = 0

@export var ball_textures: Array[Texture2D] = []

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer



var speed = 700.0
var can_go_through_ships: bool = false
var through_ships: int

var shooter: Node2D = null

func _ready() -> void:
	if !can_go_through_ships:
		through_ships = 0
	else:
		through_ships = through_ships_ball
	
	
	
	if ball_textures.size() > 0:
		sprite.texture = ball_textures.pick_random()
		rotation += randf_range(-0.1, 0.1)
		sprite.rotation += randf_range(0, TAU)
		
		var random_scale = randf_range(0.85, 1.15)
		sprite.scale *= Vector2(random_scale, random_scale)

func _physics_process(delta: float) -> void:
	position += Vector2.RIGHT.rotated(rotation) * speed * delta
	

		

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body == shooter:
		return
	
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()


func _on_timer_timeout() -> void:
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate", Color(0.0, 0.0, 0.0, 0.5), 0.5)
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.7)
	await tween.finished
	
	queue_free()

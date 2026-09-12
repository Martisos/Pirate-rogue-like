extends Area2D

@export var damage: int = 1
@export var through_ships_ball: int = 0

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
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 1.5)
	await tween.finished
	
	queue_free()

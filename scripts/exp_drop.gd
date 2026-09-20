extends Area2D

@export var exp_amount: int = 1
@export var additional_exp: int = 0
@export var sprites: Array[CompressedTexture2D] = []

@onready var sprite_2d: Sprite2D = $Sprite2D


var float_timer: float = 0.0
var base_scale: Vector2 = Vector2.ZERO

var go_to_player: bool = false
var speed = 800

var player

func _ready() -> void:

	var playersGroup = get_tree().get_nodes_in_group("player")
	if playersGroup.size() > 0:
		player = playersGroup[0]
	
	if sprite_2d != null:
		sprite_2d.texture = sprites.pick_random()
		sprite_2d.rotation = randf_range(0.0, TAU)
		
		var random_scale = randf_range(0.8, 1.2)
		base_scale = Vector2(random_scale, random_scale)
		sprite_2d.scale = base_scale
	
	float_timer = randf_range(0.0, 10.0)


func set_exp_amount(number: int) -> void:
	exp_amount = number

func set_additional_exp_amount(number: int) -> void:
	additional_exp = number

func add_additional_exp_amount(number: int) -> void:
	additional_exp += number

func _process(delta: float) -> void:
	if go_to_player:
		if player:
			global_position = global_position.move_toward(player.global_position, speed * delta)
		return
	
	float_timer += delta * 1.5
	
	var scale_wave = sin(float_timer) * 0.1
	sprite_2d.scale = base_scale + Vector2(scale_wave, scale_wave)
	
	var color_wave = remap(cos(float_timer), -1.0, 1.0, 0.8, 1.0)
	sprite_2d.modulate = Color(color_wave, color_wave, color_wave, 1.0)
	
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("gain_exp"):
			body.gain_exp(exp_amount)
			print("exp gained: ", exp_amount)
			queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("exp_magnet"):
		go_to_player = true

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("exp_magnet"):
		go_to_player = false

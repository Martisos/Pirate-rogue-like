extends Area2D

@export var exp_amount: int = 1
@export var additional_exp: int = 0

var go_to_player: bool = false
var speed = 800

var player

func _ready() -> void:
	var playersGroup = get_tree().get_nodes_in_group("player")
	if playersGroup.size() > 0:
		player = playersGroup[0]

func set_exp_amount(number: int) -> void:
	exp_amount = number

func set_additional_exp_amount(number: int) -> void:
	additional_exp = number

func add_additional_exp_amount(number: int) -> void:
	additional_exp += number

func _process(delta: float) -> void:
	if go_to_player:
		position = position.move_toward(player.position, speed * delta)

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

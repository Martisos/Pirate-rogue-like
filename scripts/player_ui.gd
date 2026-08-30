extends CanvasLayer

@onready var player: CharacterBody2D = $"../Player"

@onready var exp_bar: TextureProgressBar = $ExpBar
@onready var health_bar: TextureProgressBar = $HealthBar

#---Stats---
var max_health: int
var health: int

var shoot_cooldown: float
var bonus_damage: int

var level: int
var current_exp: float
var exp_to_new_level: float

func _ready() -> void:
	health_bar.max_value = player.max_health
	health_bar.value = player.health
	
	exp_bar.max_value = player.exp_to_new_level
	exp_bar.value = player.current_exp


func _on_player_exp_changed_signal(current_exp_s: Variant, exp_to_new_level_s: Variant) -> void:
	exp_bar.max_value = exp_to_new_level_s
	
	var tween = create_tween()
	tween.tween_property(exp_bar, "value", current_exp_s, 0.2).set_trans(Tween.TRANS_SINE)

func _on_player_health_changed_signal(current_health_s: Variant, max_health_s: Variant) -> void:
	health_bar.max_value = max_health_s
	health_bar.custom_minimum_size.x = max_health_s * 30
	
	var tween = create_tween()
	tween.tween_property(health_bar, "value", current_health_s, 0.3).set_trans(Tween.TRANS_SINE)

func _on_player_level_up_signal(new_level_s: Variant) -> void:
	await get_tree().create_timer(0.2).timeout
	
	var exp_over = player.exp_to_new_level - player.current_exp
	exp_bar.value = 0

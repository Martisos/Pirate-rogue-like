extends Node

#0 mini
#1 small
#2 medium
#3 large
@export var enemies: Array[PackedScene]

@onready var spawn_timer: Timer = $SpawnTimer

var player = null
var counter: int = 0
var base_cooldown: float = 6.0


func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _change_cooldown() -> void:
	var cooldown_based = base_cooldown * (1 - (0.05 * player.level))
	cooldown_based = max(0.5, base_cooldown)
	spawn_timer.wait_time = cooldown_based

func _on_spawn_timer_timeout() -> void:
	_change_cooldown()
	var chosen_enemy_scene: PackedScene
	
	var randomNumber = randi_range(0, 10)
	
	print(counter, ":")
	if randomNumber >= 0 and randomNumber <=4:
		chosen_enemy_scene = enemies[0]
		print("mini", randomNumber)
	elif randomNumber >= 5 and randomNumber <= 7:
		chosen_enemy_scene = enemies[1]
		print("small", randomNumber)
	elif randomNumber >= 8 and randomNumber <= 9:
		chosen_enemy_scene = enemies[2]
		print("medium", randomNumber)
	elif randomNumber == 10:
		chosen_enemy_scene = enemies[3]
		print("large", randomNumber)
	else:
		print("karamba", randomNumber)
	counter += 1
	
	
	if chosen_enemy_scene == null:
		return
	
	var enemy = chosen_enemy_scene.instantiate()
	var angle = randf() * TAU
	var distance = randf_range(1200, 3500)
	
	var spawn_offset = Vector2(cos(angle), sin(angle)) * distance
	enemy.global_position = player.global_position + spawn_offset
	
	get_tree().current_scene.add_child(enemy)

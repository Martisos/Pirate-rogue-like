extends Node

#0 mini
#1 small
#2 medium
#3 large
@export var enemies: Array[PackedScene]

@onready var spawn_timer: Timer = $SpawnTimer

var player = null

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _on_spawn_timer_timeout() -> void:
	var chosen_enemy_scene: PackedScene
	
	var randomNumber = randi_range(0, 10)
	
	if randomNumber in range(0,5):
		chosen_enemy_scene = enemies[0]
		print("mini", randomNumber)
	elif randomNumber in range(5,8):
		chosen_enemy_scene = enemies[1]
		print("small", randomNumber)
	elif randomNumber in range(8,10):
		chosen_enemy_scene = enemies[2]
		print("medium", randomNumber)
	if randomNumber == 10:
		chosen_enemy_scene = enemies[3]
		print("large", randomNumber)
	
	if chosen_enemy_scene == null:
		return
	
	var enemy = chosen_enemy_scene.instantiate()
	var angle = randf() * TAU
	var distance = randf_range(1200, 3500)
	
	var spawn_offset = Vector2(cos(angle), sin(angle)) * distance
	enemy.global_position = player.global_position + spawn_offset
	
	get_tree().current_scene.add_child(enemy)

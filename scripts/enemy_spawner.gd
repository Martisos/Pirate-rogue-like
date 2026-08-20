extends Node

@onready var enemy_scene: PackedScene = preload("uid://dwqjqohfahwf7")
@onready var spawn_timer: Timer = $SpawnTimer
@onready var player: CharacterBody2D = $"../Player"


func _on_spawn_timer_timeout() -> void:
	if enemy_scene == null or !player:
		return
	
	var enemy = enemy_scene.instantiate()
	
	var angle = randf() * TAU
	var distance = randf_range(1000, 3000)
	
	var spawn_offset = Vector2(cos(angle), sin(angle)) * distance
	enemy.global_position = player.global_position + spawn_offset
	
	get_tree().root.add_child(enemy)

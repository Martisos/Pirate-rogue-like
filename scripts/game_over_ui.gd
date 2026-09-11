extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var death_message_label: Label = $VBoxContainer/DeathMessageLabel
@onready var stats_label: Label = $VBoxContainer/StatsLabel


func _ready() -> void:
	hide()
	color_rect.modulate.a = 0.0


func show_game_over(level: int):
	show()
	
	print("pre stats label")
	stats_label.text = "Your Level: " + str(level)
	print("post stats label")
	
	color_rect.color = Color(0,0,0.0)
	
	print("creating tween")
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect, "modulate", Color(0,0,0, 1), 1.0)
	
	await tween.finished
	print("post tween")
	
	get_tree().paused = true
	print("paused")

func _on_play_again_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

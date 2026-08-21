extends CanvasLayer

@export var all_avaiable_upgrades: Array[UpgradeCard]

var player = null

func _ready() -> void:
	hide()

func show_upgrades() -> void:
	show()
	get_tree().paused = true

func _on_button_pressed() -> void:
	hide()
	get_tree().paused = false

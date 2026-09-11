extends Node2D

@onready var parallax_2d: Parallax2D = $Parallax2D


func _ready() -> void:
	if Options.water_enabled == false:
		parallax_2d.hide()
	else:
		parallax_2d.show()
	pass # Replace with function body.

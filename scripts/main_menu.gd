extends Control

@onready var buttons_node: Node = $ButtonsNode

func _ready() -> void:
	if buttons_node != null:
		var buttons = buttons_node.get_children()
		for button in buttons:
			button.modulate.a = 0.0
			button.position.x -= 600
	
		for button in buttons:
			var tween = create_tween().set_parallel(true)
			
			tween.tween_property(button, "modulate:a", 1.0, 0.5)
			
			tween.tween_property(button, "position:x", button.position.x + 600, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			
			await get_tree().create_timer(0.15).timeout
			
func _process(delta: float) -> void:
	pass

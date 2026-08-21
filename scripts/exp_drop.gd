extends Area2D

@export var exp_amount: int = 1

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("gain_exp"):
			body.gain_exp(exp_amount)
			queue_free()

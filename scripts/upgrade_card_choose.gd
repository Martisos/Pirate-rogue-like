extends TextureButton

signal card_selected(card_data)

@onready var icon: TextureRect = $TextureRect
@onready var title: Label = $Title
@onready var description: Label = $Description

var card_data: UpgradeCard

func _ready() -> void:
	hide()
	pressed.connect(_on_pressed)
	
	scale = Vector2.ZERO
	pivot_offset = size / 2.0


func setup(card: UpgradeCard, bg_texture:Texture2D) -> void:
	card_data = card
	
	title.text = card.title
	description.text = card.description
	icon.texture = card.icon
	
	if bg_texture:
		texture_normal = bg_texture
		modulate.a = 0.0
		position.y += 40
	
	show()
	
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel(true)
	
	tween.tween_property(self, "scale", Vector2.ONE, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	
func _on_pressed() -> void:
	emit_signal("card_selected", card_data)

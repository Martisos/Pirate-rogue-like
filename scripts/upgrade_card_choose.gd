extends TextureButton

signal card_selected(card_data)

@onready var icon: TextureRect = $TextureRect
@onready var title: Label = $Title
@onready var description: Label = $Description

var card_data: UpgradeCard

func _ready() -> void:
	pressed.connect(_on_pressed)


func setup(card: UpgradeCard, bg_texture:Texture2D) -> void:
	card_data = card
	
	title.text = card.title
	description.text = card.description
	icon.texture = card.icon
	
	if bg_texture:
		texture_normal = bg_texture

func _on_pressed() -> void:
	emit_signal("card_selected", card_data)

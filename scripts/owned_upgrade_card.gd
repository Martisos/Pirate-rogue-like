extends Control


@onready var icon: TextureRect = $Icon
@onready var color_rect: ColorRect = $ColorRect
@onready var title: Label = $HBoxContainer/Title
@onready var description: Label = $HBoxContainer/Description


func _ready() -> void:
	hide()

var rarity_colors = {
	UpgradeCard.rarities.common: "929b98",
	UpgradeCard.rarities.rare: "76d0ef",
	UpgradeCard.rarities.epic: "bf9dfa",
	UpgradeCard.rarities.legendary: "dba75a"
}

func setup(card: UpgradeCard):
	icon.texture = card.icon
	title.text = card.title
	description.text = card.description
	
	if rarity_colors.has(card.rarity):
		var assigned_color = rarity_colors[card.rarity]
		color_rect.color = assigned_color

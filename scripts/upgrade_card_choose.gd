extends TextureButton

signal card_selected(card_data)

@onready var icon: TextureRect = $TextureRect
@onready var title: Label = $Title
@onready var description: Label = $Description

var RARITY_SHADER_COLORS = {
	UpgradeCard.rarities.common: Color("#929b98"),
	UpgradeCard.rarities.rare: Color("#76d0ef"),
	UpgradeCard.rarities.epic: Color("#bf9dfa"),
	UpgradeCard.rarities.legendary: Color("#dba75a"),
	UpgradeCard.rarities.debuff: Color("#a62f56")
}

@export var target_size: Vector2 = Vector2(250, 350)

var card_data: UpgradeCard

func _ready() -> void:
	modulate.a = 0.0
	hide()
	pressed.connect(_on_pressed)


func setup(card: UpgradeCard, bg_texture:Texture2D) -> void:
	card_data = card
	title.text = card.title
	description.text = card.description
	icon.texture = card.icon
	
	if bg_texture:
		texture_normal = bg_texture
	
	modulate.a = 0.0
	custom_minimum_size = Vector2(0, target_size.y)
	visible = false
	scale = Vector2.ZERO
	
	var mat: ShaderMaterial = material as ShaderMaterial
	if mat:
		mat = mat.duplicate() as ShaderMaterial
		material = mat
		if RARITY_SHADER_COLORS.has(card.rarity):
			var choosen_color = RARITY_SHADER_COLORS[card.rarity]
			mat.set_shader_parameter("highlight_color", choosen_color)
	
	show()
	_start_animation.call_deferred()

func _on_pressed() -> void:
	emit_signal("card_selected", card_data)

func _start_animation():
	pivot_offset = size / 2.0
	
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel(true)
	
	tween.tween_property(self, "custom_minimum_size:x", target_size.x, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

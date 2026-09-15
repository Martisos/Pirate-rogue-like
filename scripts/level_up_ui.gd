extends CanvasLayer

@export var all_avaiable_upgrades: Array[UpgradeCard]
@onready var upgrades: Control = $Upgrades
@onready var button: Button = $Upgrades/Button
@onready var owned_upgrades_container: VBoxContainer = $Upgrades/VBoxContainer/ScrollContainer/owned_upgrades_container
@export var owned_item_scene: PackedScene = preload("uid://dt1e1s5ocrhwg")
@export var card_scene: PackedScene = preload("uid://ip8o0i2f5u1r")

@onready var cards_container: HBoxContainer = $HBoxContainer



@export var rarity_backgrounds = {
	UpgradeCard.rarities.common : preload("uid://bkaudtb81468c"),
	UpgradeCard.rarities.rare : preload("uid://cgu65sdfw0kmr"),
	UpgradeCard.rarities.epic : preload("uid://dj8y6aad5l48y"),
	UpgradeCard.rarities.legendary : preload("uid://clark0if1gxo1"),
	UpgradeCard.rarities.debuff : preload("uid://c1hwh5823g2sd")
}

var upgrades_owned_menu_shown: bool = false

var current_choices: Array[UpgradeCard] = []
var player = null

# 0 - common; 1 - rare, 2 - epic, 3 - legendary
const RARITY_WEIGHTS = {
	0: 50.0,
	1: 20.0,
	2: 10.0,
	3: 5.0,
	4: 15.0
}

func _ready() -> void:
	hide()

func show_upgrades() -> void:
	
	for child in cards_container.get_children():
		child.queue_free()
	
	if upgrades_owned_menu_shown:
		_on_button_mouse_entered()
	
	var playersGroup = get_tree().get_nodes_in_group("player")
	if playersGroup.size() > 0:
		player = playersGroup[0]
	
	if !player:
		return
	
	
	var valid_upgrades: Array[UpgradeCard] = []
	for upgrade in all_avaiable_upgrades:
		if upgrade.upgrade_type == "heal" and player.health >= player.max_health:
			continue
		if upgrade.one_time_use and upgrade in PlayerUpgrades.upgrades:
			continue
		valid_upgrades.append(upgrade)
	
	# random upgrades
	current_choices.clear()
	var num_to_pick = min(3, valid_upgrades.size())
	
	for i in range(num_to_pick):
		var current_weights = {}
		var total_weight = 0.0
		
		for card in valid_upgrades:
			if not current_weights.has(card.rarity):
				current_weights[card.rarity] = RARITY_WEIGHTS[card.rarity]
				total_weight += RARITY_WEIGHTS[card.rarity]
		
		var roll = randf_range(0.0, total_weight)
		var current_sum = 0.0
		var chosen_rarity = -1
		
		for rarity in current_weights.keys():
			current_sum += current_weights[rarity]
			if roll <= current_sum:
				chosen_rarity = rarity
				break
		
		var cards_of_chosen_rarity: Array[UpgradeCard] = []
		for card in valid_upgrades:
			if card.rarity == chosen_rarity:
				cards_of_chosen_rarity.append(card)
		
		var picked_card = cards_of_chosen_rarity.pick_random()
		
		print(picked_card.rarity, " ", picked_card.title)
		current_choices.append(picked_card)
		
		valid_upgrades.erase(picked_card)
		
		
	show()
	get_tree().paused = true
	
	for child  in cards_container.get_children():
		child.queue_free()
	
	for card in current_choices:
		await get_tree().create_timer(0.2).timeout
		
		var new_card = card_scene.instantiate()
		cards_container.add_child(new_card)
		
		var bg_texture: Texture2D = rarity_backgrounds.get(card.rarity, null)
		new_card.setup(card, bg_texture)
		
		new_card.card_selected.connect(_on_custom_card_selected)

func _on_custom_card_selected(card_data: UpgradeCard) -> void:
	var index = current_choices.find(card_data)
	if index != -1:
		_on_card_selected(index)

func _on_card_selected(index: int) -> void:
	var selected_upgrade: UpgradeCard = current_choices[index]
	
	PlayerUpgrades.add_upgrade(selected_upgrade)
	
	selected_upgrade.apply_upgrade(player)
	update_owned_upgrades_display()
	
	hide()
	get_tree().paused = false
	
	if player.has_method("process_next_level_up"):
		player.process_next_level_up()


func update_owned_upgrades_display():
	for child in owned_upgrades_container.get_children():
		child.queue_free()
	
	for card in PlayerUpgrades.upgrades:
		if owned_item_scene != null:
			var item_node = owned_item_scene.instantiate()
			owned_upgrades_container.add_child(item_node)
			
			if item_node.has_method("setup"):
				print("added child '", card.title, "' and setup!")
				item_node.setup(card)
				item_node.show()


func _on_button_mouse_entered() -> void:
	upgrades_owned_menu_shown = !upgrades_owned_menu_shown
	
	if !upgrades_owned_menu_shown:
		upgrades.position.x += 300
		button.text = "<"
	else:
		upgrades.position.x -= 300
		button.text = ">"
		update_owned_upgrades_display()
	

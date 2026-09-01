extends CanvasLayer

@export var all_avaiable_upgrades: Array[UpgradeCard]
@onready var upgrades: Control = $Upgrades
@onready var button: Button = $Upgrades/Button

var upgrades_owned_menu_shown: bool = false

@onready var card_buttons: Array[Button] = [
	$HBoxContainer/Card1,
	$HBoxContainer/Card2,
	$HBoxContainer/Card3
]

var current_choices: Array[UpgradeCard] = []
var player = null

# 0 - common; 1 - rare, 2 - epic, 3 - legendary
const RARITY_WEIGHTS = {
	0: 40.0,
	1: 30.0,
	2: 20.0,
	3: 10.0
}

func _ready() -> void:
	hide()
	
	for i in range(card_buttons.size()):
		card_buttons[i].pressed.connect(_on_card_selected.bind(i))

func show_upgrades() -> void:
	
	if upgrades_owned_menu_shown:
		_on_button_mouse_entered()
	
	
	var playersGroup = get_tree().get_nodes_in_group("player")
	if playersGroup.size() > 0:
		player = playersGroup[0]
	
	if !player:
		return
	
	for button in card_buttons:
		button.hide()
	
	var valid_upgrades: Array[UpgradeCard] = []
	
	for upgrade in all_avaiable_upgrades:
		if upgrade.upgrade_type == "heal" and player.health >= player.max_health:
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
	
	for i in range(card_buttons.size()):
		if i < current_choices.size():
			await get_tree().create_timer(0.5).timeout
			var card = current_choices[i]
			card_buttons[i].show()
			card_buttons[i].text = card.title + "\n\n" + card.description
			
			card_buttons[i].icon = card.icon
		else:
			card_buttons[i].hide()
	

	

func _on_card_selected(index: int) -> void:
	var selected_upgrade: UpgradeCard = current_choices[index]
	
	selected_upgrade.apply_upgrade(player)
	hide()
	get_tree().paused = false
	
	if player.has_method("process_next_level_up"):
		player.process_next_level_up()


func _on_button_mouse_entered() -> void:
	upgrades_owned_menu_shown = !upgrades_owned_menu_shown
	
	if !upgrades_owned_menu_shown:
		upgrades.position.x += 300
		button.text = "<"
	else:
		upgrades.position.x -= 300
		button.text = ">"
	

extends CanvasLayer

@export var all_avaiable_upgrades: Array[UpgradeCard]

@onready var card_buttons: Array[Button] = [
	$HBoxContainer/Card1,
	$HBoxContainer/Card2,
	$HBoxContainer/Card3
]

var current_choices: Array[UpgradeCard] = []

var player = null


func _ready() -> void:
	hide()
	
	for i in range(card_buttons.size()):
		card_buttons[i].pressed.connect(_on_card_selected.bind(i))

func show_upgrades() -> void:
	
	var playersGroup = get_tree().get_nodes_in_group("player")
	if playersGroup.size() > 0:
		player = playersGroup[0]
	
	if !player:
		return
	
	var valid_upgrades: Array[UpgradeCard] = []
	
	for upgrade in all_avaiable_upgrades:
		if upgrade.upgrade_type == "heal" and player.health >= player.max_health:
			continue
		valid_upgrades.append(upgrade)
	
	valid_upgrades.shuffle()
	
	current_choices = valid_upgrades.slice(0,3)
	
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

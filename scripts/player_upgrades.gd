extends Node

var upgrades: Array[UpgradeCard] = [] 


func add_upgrade(card: UpgradeCard):
	upgrades.append(card)
	print(upgrades[0].title, " append!")

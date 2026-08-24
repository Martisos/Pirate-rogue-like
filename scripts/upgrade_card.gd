extends Resource
class_name UpgradeCard

enum rarities {common, rare, epic, legendary}

@export var title: String = "Upgrade Name"
@export_multiline var description: String = "Upgrade description"
@export var rarity: rarities = rarities.common
@export var icon: Texture2D 

@export_enum("speed", "damage", "max_health", "heal", "attack_speed", "add_cannon") var upgrade_type: String = "speed"

@export var value: float = 1.0

func apply_upgrade(player: CharacterBody2D) -> void:
	match upgrade_type:
		"speed":
			player.speed += int(value)
			player.turn_speed += value / 200
			print("new speed: ", player.speed)
			print("new turn speed: ", player.turn_speed)
		"damage":
			player.bonus_damage += int(value)
			print("new damage: ", 1 + player.bonus_damage)
		"max_health":
			player.max_health += int(value)
			
			if player.health + int(value) > player.max_health:
				player.health = player.max_health
			else:
				player.health += int(value)
			print("new max health:", player.max_health)
		"heal":
			if player.health + int(value) > player.max_health:
				player.health = player.max_health
			else:
				player.health += int(value)
			print("player health: ", player.health)
		"attack_speed":
			player.shoot_cooldown /= value
			print("shooting got " , value, " times faster!")
		"add_cannon":
			#it for sure will work in future
			print("totally added new cannon")

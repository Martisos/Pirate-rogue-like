extends Resource
class_name UpgradeCard

enum rarities {common, rare, epic, legendary, debuff}

@export var title: String = "Upgrade Name"
@export_multiline var description: String = "Upgrade description"
@export var rarity: rarities = rarities.common
@export var icon: Texture2D 
@export var one_time_use: bool = false

@export_enum(
	"speed", "damage", "max_health",
	"heal", "attack_speed", "add_cannon", 
	"magnet_size", "camera_zoom",
	"debuff_enemy_speed", "debuff_cannonball_speed",
	"debuff_enemy_attack_speed"
) var upgrade_type: String = "speed"



@export var value: float = 1.0
@export var value2: float = 1.0

func apply_upgrade(player: CharacterBody2D) -> void:
	match upgrade_type:
		"speed": #done
			player.speed += int(value)
			player.turn_speed += value / 200
			print("new speed: ", player.speed)
			print("new turn speed: ", player.turn_speed)
		"damage": #done
			player.bonus_damage += int(value)
			print("new damage: ", 1 + player.bonus_damage)
		"max_health": #done
			player.max_health += int(value)
			
			if player.health + int(value) > player.max_health:
				player.health = player.max_health
			else:
				player.health += int(value)
			player.health_changed_signal.emit(player.health, player.max_health)
			print("new max health:", player.max_health)
		"heal": #done
			var flat_heal: int = int(value)
			var percentage_value: float = value2 #value will be %
			var percent_heal = int(player.max_health * (percentage_value / 100.0))
			
			var final_heal = max(value, flat_heal)
			
			if final_heal < 1:
				final_heal = 1
			
			player.health = min(player.health + final_heal, player.max_health)
			
			player.health_changed_signal.emit(player.health, player.max_health)
			print("player health: ", player.health)
		"attack_speed": #done
			player.shoot_cooldown /= value
			print("shooting got " , value, " times faster!")
		"add_cannon":
			#it for sure will work in future
			print("totally added new cannon")
		"magnet_size": #done
			player.magnet_area_size *= value
			player.apply_unique_upgrades()
			print("player area multiplier:", player.magnet_area_size)
		"camera_zoom":
			player.camera_zoom = player.camera_zoom / value
			player.apply_unique_upgrades()
		"debuff_enemy_speed":
			EnemyDebuffs.speed_debuff_multiplier *= value
		"debuff_cannonball_speed":
			EnemyDebuffs.cannonball_speed_debuff_multiplier *= value
		"debuff_enemy_attack_speed":
			EnemyDebuffs.attack_speed_debuff_multiplier *= value

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
		"speed":
			player.speed += int(value)
			player.turn_speed += value / 200
		"damage":
			player.bonus_damage += int(value)
		"max_health":
			player.max_health += int(value)
			
			if player.health + int(value) > player.max_health:
				player.health = player.max_health
			else:
				player.health += int(value)
			player.health_changed_signal.emit(player.health, player.max_health)
		"heal":
			var flat_heal: int = int(value)
			var percentage_value: float = value2 #value will be %
			var percent_heal = int(player.max_health * (percentage_value / 100.0))
			
			var final_heal = max(percent_heal, flat_heal)
			
			if final_heal < 1:
				final_heal = 1
			
			player.health = min(player.health + final_heal, player.max_health)
			
			player.health_changed_signal.emit(player.health, player.max_health)
		"attack_speed":
			player.shoot_cooldown /= value
		"add_cannon":
			pass
			#it for sure will work in future
		"magnet_size":
			player.magnet_area_size *= value
			player.apply_unique_upgrades()
		"camera_zoom":
			player.camera_zoom = player.camera_zoom / value
			player.apply_unique_upgrades()
		"debuff_enemy_speed":
			EnemyDebuffs.speed_debuff_multiplier *= value
		"debuff_cannonball_speed":
			EnemyDebuffs.cannonball_speed_debuff_multiplier *= value
		"debuff_enemy_attack_speed":
			EnemyDebuffs.attack_speed_debuff_multiplier *= value

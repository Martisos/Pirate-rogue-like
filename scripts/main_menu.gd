extends Control

@onready var buttons_node: Control = $ButtonsNode
@onready var settings_bg: ColorRect = $SettingsBg
@onready var settings_panel: VBoxContainer = $SettingsPanel

@onready var camera_shake_check_box: CheckBox = $SettingsPanel/CameraShake/HBoxContainer/CameraShakeCheckBox
@onready var water_enable_check_box: CheckBox = $SettingsPanel/WaterEnable/HBoxContainer/WaterEnableCheckBox
@onready var sound_manager: Node = $SoundManager
@onready var music_h_slider: HSlider = $SettingsPanel/Music/HBoxContainer/MusicHSlider
@onready var sfxh_slider: HSlider = $SettingsPanel/Music2/HBoxContainer/SFXHSlider
@onready var paralaxes: Node = $Paralaxes
@onready var color_rect_water: Sprite2D = $"Water-additional/Sprite2D"

@onready var water_additional: Parallax2D = $"Water-additional"

@onready var sprite_ship: Sprite2D = $Node2D/Sprite2D

var is_floating: bool = false
var time_passed: float = 0.0
var initial_ship_y: float = 0.0
var initial_ship_rot: float = 0.0


func _ready() -> void:
	music_h_slider.value = Options.music_volume
	sfxh_slider.value = Options.sfx_volume
	
	$SoundManager.play_menu_music()
	
	
	var paralaxCounter = 0
	for paralax in paralaxes.get_children():
		var sprite = paralax.get_node_or_null("Sprite2D")
		if paralaxCounter == 0:
			sprite.position = Vector2(250.0, 760.0)
		elif paralaxCounter == 1:
			sprite.position = Vector2(381.0, 745.0)
		else:
			sprite.position = Vector2(533.0, 730.0)
		
		paralaxCounter += 1
		
	if sprite_ship != null:
		
		sprite_ship.global_position = Vector2(1475, 402)
		sprite_ship.show()
	
	if color_rect_water != null:
		color_rect_water.position = Vector2(251, 1071)
		color_rect_water.visible = true
		
	if buttons_node != null:
		settings_bg.visible = false
		settings_panel.visible = false
		
		var buttons = buttons_node.get_children()
		for button in buttons:
			button.modulate.a = 0.0
			button.position.x -= 600
		
		var current_index = 0
		for paralax in paralaxes.get_children():
			var sprite = paralax.get_node_or_null("Sprite2D")
			
			
			if sprite != null:
				var paralax_tween = create_tween().set_parallel(true)
				paralax_tween.tween_property(sprite, "position:y", sprite.position.y - 200, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				
				if current_index == 0 and color_rect_water != null:
					paralax_tween.tween_property(color_rect_water, "position:y", color_rect_water.position.y - 200, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				
				await get_tree().create_timer(0.7).timeout
				current_index += 1
				
				if current_index == 3:
					_animate_ship()
					await get_tree().create_timer(2.8).timeout
					_animate_buttons()

func _process(delta: float) -> void:
	if is_floating and sprite_ship != null:
		time_passed += delta * 1.0
		
		sprite_ship.position.y = initial_ship_y + sin(time_passed) * 15.0 #15 pixels
		
		sprite_ship.rotation = initial_ship_rot + cos(time_passed) * 0.02

func _animate_buttons() -> void:
	var buttons = buttons_node.get_children()
	for button in buttons:
		var tween = create_tween().set_parallel(true)
		
		tween.tween_property(button, "modulate:a", 1.0, 0.5)
		
		tween.tween_property(button, "position:x", button.position.x + 600, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _animate_ship() -> void:
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(sprite_ship, "position:x", sprite_ship.position.x - 700, 2.8)
	initial_ship_y = sprite_ship.position.y
	initial_ship_rot = sprite_ship.rotation
	is_floating = true
	
	
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world1.tscn")

func _on_settings_pressed() -> void:
	buttons_node.hide()
	sprite_ship.hide()
	settings_bg.visible = true
	settings_panel.visible = true


func _on_button_pressed() -> void:
	buttons_node.show()
	settings_bg.visible = false
	settings_panel.visible = false
	_ready()


func _on_camera_shake_check_box_toggled(toggled_on: bool) -> void:
	Options.camera_shake = toggled_on


func _on_water_enable_check_box_toggled(toggled_on: bool) -> void:
	Options.water_enabled = toggled_on


func _on_show_stats_check_box_toggled(toggled_on: bool) -> void:
	Options.show_stats = toggled_on

#music
func _on_music_h_slider_value_changed(value: float) -> void:
	sound_manager.set_music_volume(value)
	Options.music_volume = value


func _on_sfxh_slider_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("SFX")
	Options.sfx_volume = value
	
	if value == 0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

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



func _ready() -> void:
	music_h_slider.value = Options.music_volume
	sfxh_slider.value = Options.sfx_volume
	
	$SoundManager.play_menu_music()
	
	var paralaxCounter = 0
	for paralax in paralaxes.get_children():
		var sprite = paralax.get_node_or_null("Sprite2D")
		if paralaxCounter == 0:
			sprite.position = Vector2(250.0, 773.0)
		if paralaxCounter == 1:
			sprite.position = Vector2(381.0, 745.0)
		else:
			sprite.position = Vector2(533.0, 748.0)
		paralaxCounter += 1

	for paralax in paralaxes.get_children():
		var sprite = paralax.get_node_or_null("Sprite2D")
		
		if sprite != null:
			var paralax_tween = create_tween().set_parallel(true)
			paralax_tween.tween_property(sprite, "position:y", sprite.position.y - 200, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

			print(sprite.position)

	if buttons_node != null:
		settings_bg.visible = false
		settings_panel.visible = false
		
		var buttons = buttons_node.get_children()
		for button in buttons:
			button.modulate.a = 0.0
			button.position.x -= 600
	
		for button in buttons:
			var tween = create_tween().set_parallel(true)
			
			tween.tween_property(button, "modulate:a", 1.0, 0.5)
			
			tween.tween_property(button, "position:x", button.position.x + 600, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			
			await get_tree().create_timer(0.15).timeout
			

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world1.tscn")

func _on_settings_pressed() -> void:
	buttons_node.hide()
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

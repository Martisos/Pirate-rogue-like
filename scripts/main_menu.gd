extends Control

@onready var buttons_node: Control = $ButtonsNode
@onready var settings_bg: ColorRect = $SettingsBg
@onready var settings_panel: VBoxContainer = $SettingsPanel

@onready var camera_shake_check_box: CheckBox = $SettingsPanel/CameraShake/HBoxContainer/CameraShakeCheckBox
@onready var water_enable_check_box: CheckBox = $SettingsPanel/WaterEnable/HBoxContainer/WaterEnableCheckBox




func _ready() -> void:
	if buttons_node != null:
		
		#-----------------
		#-----------------
		
		
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
			
func _process(delta: float) -> void:
	pass

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

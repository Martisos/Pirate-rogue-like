extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer

var menu_music
var battle_music

func play_menu_music() -> void:
	if music_player.stream != menu_music:
		music_player.stram = menu_music
		music_player.play()

func play_battle_music() -> void:
	if music_player.stream != battle_music:
		music_player.stream = battle_music
		music_player.play()


func set_music_volume(slider_value: float) -> void:
	if slider_value == 0:
		music_player.volume_db =- 80 #nothing
	else:
		music_player.volume_db = linear_to_db(slider_value)

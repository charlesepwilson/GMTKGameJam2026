class_name VictoryPopup
extends Control

var is_random_level: bool = false

func _on_next_level_button_pressed():
	if is_random_level:
		var random_level: PackedScene = LevelGenerator.generate_and_pack_level()
		Settings.current_packed_scene = random_level
		get_tree().change_scene_to_packed(random_level)
	else:
		Settings.load_level(Settings.current_level_number + 1)

func _on_retry_button_pressed():
	if is_random_level:
		get_tree().change_scene_to_packed(Settings.current_packed_scene)
	else:
		get_tree().reload_current_scene()

func _on_level_select_button_pressed():
	get_tree().change_scene_to_file("res://level_select/level_select.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%NextLevel.pressed.connect(_on_next_level_button_pressed)
	%Retry.pressed.connect(_on_retry_button_pressed)
	%LevelSelect.pressed.connect(_on_level_select_button_pressed)

class_name VictoryPopup
extends Control

var level_number: int

func _on_next_level_button_pressed():
	get_tree().change_scene_to_file(
		"res://levels/Level{level_number}.tscn".format(
			{"level_number": level_number + 1}
		)
	)

func _on_retry_button_pressed():
	get_tree().reload_current_scene()

func _on_level_select_button_pressed():
	get_tree().change_scene_to_file("res://level_select/level_select.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PanelContainer/MarginContainer/VBoxContainer/NextLevel.pressed.connect(_on_next_level_button_pressed)
	$PanelContainer/MarginContainer/VBoxContainer/Retry.pressed.connect(_on_retry_button_pressed)
	$PanelContainer/MarginContainer/VBoxContainer/LevelSelect.pressed.connect(_on_level_select_button_pressed)

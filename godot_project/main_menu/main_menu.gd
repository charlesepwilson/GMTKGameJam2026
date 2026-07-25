extends Control

@onready var settings_page = $SettingsPage


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://level_select/level_select.tscn")


func _on_settings_button_pressed():
	settings_page.visible = true



func _on_exit_pressed():
	get_tree().quit()

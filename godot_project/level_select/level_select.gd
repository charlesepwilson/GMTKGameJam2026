extends Control

@onready var button_box: VBoxContainer = $MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer

func _ready():
	button_box.find_child("Level1Button").grab_focus()
	button_box.find_child("GoBackButton").pressed.connect(
		func(): get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
	)
	for button in button_box.find_children("Level*Button", "Button"):
		button.pressed.connect(
			func(): get_tree().change_scene_to_file("res://levels/{scene}.tscn".format({"scene": button.name.trim_suffix("Button")}))
		)

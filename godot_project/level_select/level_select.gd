extends Control

@onready var button_box: GridContainer = %ButtonBox

func _make_level_button(level_number: int):
	var button = Button.new()
	button.text = "Level " + str(level_number)
	button_box.add_child(button)
	button.pressed.connect(
		func(): Settings.load_level(level_number)
	)

func _ready():
	for i in len(Settings.levels):
		_make_level_button(i + 1)

	var button = Button.new()
	button.text = "Go Back"
	$MenuContainer/VBoxContainer.add_child(button)
	button.pressed.connect(
		func(): get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
	)

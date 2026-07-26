extends Control

@onready var button_box: GridContainer = %ButtonBox

func _make_level_button(level_number: int):
	var button = Button.new()
	button.text = "Level " + str(level_number)
	button_box.add_child(button)
	button.pressed.connect(
		func(): Settings.load_level(level_number)
	)

func _make_other_button(text, callback):
	var button = Button.new()
	button.text = text
	$MenuContainer/VBoxContainer.add_child(button)
	button.pressed.connect(callback)

func _load_random_level():
	var random_level: PackedScene = LevelGenerator.generate_and_pack_level()
	Settings.current_packed_scene = random_level
	get_tree().change_scene_to_packed(random_level)


func _ready():
	for i in len(Settings.levels):
		_make_level_button(i + 1)

	_make_other_button(
		"Random Generated Level",
		_load_random_level,
	)
	_make_other_button(
		"Go Back",
		func(): get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
	)

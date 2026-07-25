extends Control

@onready var button_box: GridContainer = %ButtonBox
@export var total_levels: int = 12

func _make_button(button_text: String, scene: String, _parent = button_box):
	var button = Button.new()
	button.text = button_text
	_parent.add_child(button)
	button.pressed.connect(
		func(): get_tree().change_scene_to_file(scene)
	)

func _ready():
	for i in range(1, total_levels + 1):
		_make_button(
			"Level " + str(i),
			"res://levels/Level{scene}.tscn".format(
				{"scene": str(i)}
			)
		)
	_make_button(
		"Go Back",
		"res://main_menu/main_menu.tscn",
		$MenuContainer/VBoxContainer,
	)

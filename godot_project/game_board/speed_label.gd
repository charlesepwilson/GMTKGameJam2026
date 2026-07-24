extends Label

func _ready() -> void:
	update_text()

func update_text():
	text = "{s}x".format({"s": Settings.game_speed / Settings.base_speed})

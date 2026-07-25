extends Button


func _ready() -> void:
	pressed.connect(speed_down)

signal speed_changed()

func speed_down():
	Settings.game_speed = move_toward(
		Settings.game_speed,
		Settings.maximum_game_speed,
		Settings.speed_increment,
	)
	speed_changed.emit()

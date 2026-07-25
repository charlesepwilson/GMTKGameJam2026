
extends Card

@export var spin_targets: Array[Vector2i] = [
	Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT
]
@export var num_quarter_turns: int = 1  # negative for anticlockwise

func _rotate_vector(v: Vector2i) -> Vector2i:
	return Vector2i(-v.y, v.x)
func _unrotate_vector(v: Vector2i) -> Vector2i:
	return Vector2i(v.y, -v.x)


func spin():
	var move_requests: Dictionary[Card, Vector2i] = {}
	for target in spin_targets:
		var target_pos: Vector2i = current_grid_position + target
		var target_card = game_board.card_grid_spaces.get(target_pos)
		if target_card is Card:
			var move_to = target
			for turn in abs(num_quarter_turns):
				if num_quarter_turns > 0:
					move_to = _rotate_vector(move_to)
				else:
					move_to = _unrotate_vector(move_to)
			move_requests[target_card] = move_to + current_grid_position
	game_board.move_multiple_simultaneously(move_requests)




func do_card_effect():
	spin()


func _describe_effect() -> String:
	return "Rotates everything adjacent a quarter turn clockwise"


@onready var vfx: Sprite2D = $VFX
var vfx_tween: Tween

func _animate_vfx():
	vfx.scale = 0.7 * Vector2.ONE
	vfx.modulate = Color.TRANSPARENT
	vfx.rotation_degrees = 0
	vfx.show()
	if vfx_tween:
		vfx_tween.kill()
	vfx_tween = get_tree().create_tween()
	vfx_tween.tween_property(
		vfx, "modulate", Color.WHITE, 0.1  / Settings.game_speed
	)
	var spin_time: float = 0.8
	vfx_tween.tween_property(
		vfx,"scale", 1.5 * Vector2.ONE, spin_time / Settings.game_speed
	).set_ease(Tween.EASE_IN_OUT)
	vfx_tween.parallel().tween_property(
		vfx, "rotation_degrees", 90, spin_time / Settings.game_speed
	).set_ease(Tween.EASE_IN)

	vfx_tween.tween_property(
		vfx, "scale", 0.7 * Vector2.ONE, spin_time / Settings.game_speed
	).set_ease(Tween.EASE_IN_OUT)
	vfx_tween.parallel().tween_property(
		vfx, "rotation_degrees", 180, spin_time / Settings.game_speed
	).set_ease(Tween.EASE_OUT)

	vfx_tween.tween_property(
		vfx, "modulate", Color.TRANSPARENT, 0.3  / Settings.game_speed
	)
	vfx_tween.tween_callback(vfx.hide)

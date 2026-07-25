extends Card

@export var explode_strength: int = 1
# @export var explode_range: int = 1

func explode():
	for direction in [
		Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT
	]:
		var target_position = current_grid_position + direction.sign()
		var target_card = game_board.card_grid_spaces.get(target_position)
		if target_card is Card:
			target_card.push(direction * explode_strength)



func do_card_effect():
	explode()

func _describe_effect() -> String:
	return "Pushes everything adjacent away"

@onready var vfx: Sprite2D = $VFX
var vfx_tween: Tween

func _animate_vfx():
	vfx.scale = 0.41 * Vector2.ONE
	vfx.modulate = Color.TRANSPARENT
	vfx.show()
	if vfx_tween:
		vfx_tween.kill()
	vfx_tween = get_tree().create_tween()
	vfx_tween.tween_property(
		vfx, "modulate", Color.WHITE, 0.3  / Settings.game_speed
	)
	vfx_tween.tween_property(
		vfx, "scale", 1.45 * Vector2.ONE, 0.5 / Settings.game_speed
	)
	vfx_tween.tween_property(
		vfx, "modulate", Color.TRANSPARENT, 0.3  / Settings.game_speed
	)
	vfx_tween.tween_callback(vfx.hide)

extends Card


@export var suck_strength: int = 1
@export var suck_range: int = 2

func suck():
	for direction in [
		Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT
	]:
		var target_position = current_grid_position + suck_range * direction.sign()
		var target_card = game_board.card_grid_spaces.get(target_position)
		if target_card is Card:
			target_card.push(direction * suck_strength * -1)



func do_card_effect():
	suck()

func _describe_effect() -> String:
	return "Pulls anything in range in a straight line towards them."

@onready var vfx: Sprite2D = $VFX
var vfx_tween: Tween

func _animate_vfx():
	vfx.scale = 2 * Vector2.ONE
	vfx.modulate = Color.TRANSPARENT
	vfx.show()
	if vfx_tween:
		vfx_tween.kill()
	vfx_tween = get_tree().create_tween()
	vfx_tween.tween_property(
		vfx, "modulate", Color.WHITE, 0.3  / Settings.game_speed
	)
	vfx_tween.tween_property(
		vfx, "scale", 0.4 * Vector2.ONE, 0.5 / Settings.game_speed
	)
	vfx_tween.tween_property(
		vfx, "modulate", Color.TRANSPARENT, 0.3  / Settings.game_speed
	)
	vfx_tween.tween_callback(vfx.hide)

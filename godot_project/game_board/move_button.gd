extends CanvasItem

const glow_material: Material = preload("res://blotchy_outline_material.tres")
const non_glow_material: Material = preload("res://non_glow_material.tres")

var glowing: bool = false

var player_cards: PlayerCards

func glow():
	if not glowing:
		glowing = true
		self_modulate = Color.WHITE
		set_material(glow_material)

func stop_glow():
	if glowing:
		glowing = false
		self_modulate = Color.TRANSPARENT
		set_material(non_glow_material)

func decide_glow():
	if player_cards.draw_pile or player_cards.hand:
		stop_glow()
	else:
		glow()

func _process(delta: float) -> void:
	if player_cards:
		decide_glow()

func _ready():
	glowing = (material == glow_material)
	stop_glow()

@tool
extends EditorScript
class_name LevelGenerator

const base_level_scene: PackedScene = preload("res://game_board/game_board.tscn")

const card_scenes: Array[PackedScene] = [
	preload("res://card/chucker/chucker.tscn"),
	preload("res://card/exploder/exploder.tscn"),
	preload("res://card/goomba/goomba.tscn"),
	preload("res://card/jumper/jumper.tscn"),
	preload("res://card/slider/slider.tscn"),
	preload("res://card/spinner/spinner.tscn"),
	preload("res://card/sucker/sucker.tscn"),
]

static func generate_card(number: int) -> Card:
	var card: Card = card_scenes.pick_random().instantiate()
	card.card_number = number
	if card.get("move_vector"):
		card.move_vector = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT].pick_random()
	var trigger = [Card.EFFECT_TRIGGER.ON_CARD_PLAYED, Card.EFFECT_TRIGGER.ON_TURN_END].pick_random()
	card.effect_triggers = [trigger]
	card.starts_on_board = randf() < 0.3
	return card

static func generate_cards() -> Array[Card]:
	var cards: Array[Card] = []
	var grid_size = 4
	var num_cards: int = randi_range(4, 8)
	var grid_positions_taken = []
	for i in num_cards:
		var card: Card = generate_card(i + 1)
		if card.starts_on_board:
			var grid_position = Vector2i(randi_range(0, grid_size), randi_range(0, grid_size))
			if grid_position not in grid_positions_taken:
				card.current_grid_position = grid_position
				grid_positions_taken.append(grid_position)
			else:
				card.starts_on_board = false
		cards.append(card)
	return cards


static func generate_word(length):
	var chars = 'abcdefghijklmnopqrstuvwxyz'
	var word: String
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi()% n_char]
	return word

static func generate_level() -> GameBoard:
	var level: GameBoard = base_level_scene.instantiate()
	level.is_random_level = true
	var player_cards: PlayerCards = level.find_child("PlayerCards")
	for card in generate_cards():
		player_cards.add_child(card)
		card.owner = level
	return level

static func pack_level(level) -> PackedScene:
	var packed_scene = PackedScene.new()
	packed_scene.pack(level)
	return packed_scene

static func generate_and_pack_level() -> PackedScene:
	return pack_level(generate_level())

static func save_level(level: GameBoard):
	var packed_scene = pack_level(level)
	var level_name = "res://levels/GeneratedLevel-"
	level_name += generate_word(25)
	level_name += ".tscn"
	print(level_name)
	ResourceSaver.save(packed_scene, level_name)

static func generate_and_save_level():
	save_level(generate_level())


func _run():
	generate_and_save_level()

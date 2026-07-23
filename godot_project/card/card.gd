@abstract
class_name Card
extends Node2D

enum CARD_MODE {DECK, HAND, CONTROL, BOARD, DISCARD}

@export var card_number: int = 1
@onready var number_label: Label = $NumberLabel
@export var current_grid_position: Vector2i = Vector2i.DOWN * 3 + Vector2i.RIGHT
var game_board: GameBoard
var player_cards: PlayerCards

var max_move_speed: float = 800
@onready var sprite: Sprite2D = $Sprite2D

var card_mode: CARD_MODE = CARD_MODE.DECK

@onready var clickable_area: Area2D = $Area2D

func _ready() -> void:
	number_label.text = str(card_number)
	game_board = find_parent("GameBoard")
	player_cards = game_board.find_child("PlayerCards")
	await player_cards.ready
	visible = false
	player_cards.draw_pile.append(self)

	clickable_area.input_event.connect(_clickable_area_input_event)

func _clickable_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if card_mode != CARD_MODE.HAND:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			card_mode = CARD_MODE.CONTROL
			reparent(game_board.grid_occupiers)

func grid_space_input_event(source: GridSpace, event: InputEvent):
	if card_mode != CARD_MODE.CONTROL:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released():
			var grid_pos: Vector2i = source.grid_position
			if game_board.can_place_here(grid_pos):
				play_card(grid_pos)


func add_to_hand():
	card_mode = CARD_MODE.HAND
	visible = true

func send_to_discard():
	card_mode = CARD_MODE.DISCARD
	reparent(player_cards)
	if self in player_cards.draw_pile:
		player_cards.draw_pile.erase(self)
	if self in player_cards.hand:
		player_cards.hand.erase(self)
	if game_board.card_grid_spaces.get(current_grid_position) == self:
		game_board.card_grid_spaces.erase(current_grid_position)
	player_cards.discard_pile.append(self)
	visible = false


func play_card(grid_position: Vector2i):
	if game_board.can_place_here(grid_position):
		if player_cards.play_card(self):
			card_mode = CARD_MODE.BOARD
			reparent(game_board.grid_occupiers)
			set_grid_position(grid_position)
			var grid_space_size: Vector2 = game_board.grid_visual.get_grid_space_size()
			var texture_size: Vector2 = sprite.texture.get_size()
			scale = min(grid_space_size.x, grid_space_size.y) / max(texture_size.x, texture_size.y) * Vector2.ONE
			on_play_effect()
		else:
			print("WARNING: Attempted to play card that's not in hand ", self)
	else:
		print("WARNING: Attempted to play card in invalid position ", grid_position)

func get_target_position() -> Vector2:
	match card_mode:
		CARD_MODE.BOARD:
			return game_board.get_physical_position(current_grid_position)
		CARD_MODE.HAND:
			return player_cards.get_card_physical_position(self)
		CARD_MODE.CONTROL:
			return game_board.grid_occupiers.get_local_mouse_position()
		_:
			return Vector2(-500, 0)

func _process(delta: float) -> void:
	position = position.move_toward(
		get_target_position(),
		delta * max_move_speed,
	)

func set_grid_position(grid_position: Vector2i):
	if game_board.can_place_here(grid_position):
		game_board.card_grid_spaces.erase(current_grid_position)
		current_grid_position = grid_position
		game_board.card_grid_spaces[current_grid_position] = self
	else:
		print("WARNING: Attempted to set card position to invalid place ", grid_position)

func slide(direction: Vector2i):
	var final_position = current_grid_position + direction
	assert(direction.x == 0 or direction.y == 0)  # for now this keeps things simple
	for step in int(direction.length()):
		if current_grid_position == final_position:
			return
		var next_position = current_grid_position + direction.sign()
		if next_position in game_board.card_grid_spaces:
			return
		if not game_board.is_inside_grid(next_position):
			return
		set_grid_position(next_position)



func on_play_effect():
	pass

func on_turn_end_effect():
	pass

func on_moved_effect():
	pass

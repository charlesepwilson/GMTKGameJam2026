class_name Card
extends Node2D

enum CARD_MODE {DECK, HAND, CONTROL, BOARD, DISCARD}

@export var card_number: int = 1
@onready var number_label: Label = $NumberLabel
@export var current_grid_position: Vector2i = Vector2i.DOWN * 3 + Vector2i.RIGHT
var game_board: GameBoard
var player_cards: PlayerCards

var max_move_speed: float = 800
@onready var sprite: Sprite2D = $Artwork

var card_mode: CARD_MODE = CARD_MODE.DECK

@onready var clickable_area: Area2D = $Area2D
@onready var sfx = $AudioStreamPlayer2D
@export var sfx_start: float = 0
var rng = RandomNumberGenerator.new()

var hovered_grid_spaces: int = 0

func _ready() -> void:
	_randomise_sfx()
	number_label.text = str(card_number)
	game_board = find_parent("GameBoard")
	player_cards = game_board.find_child("PlayerCards")
	visible = false
	clickable_area.input_event.connect(_clickable_area_input_event)

func _randomise_sfx():
	sfx.pitch_scale = rng.randfn(1.0, 0.15)
	sfx.volume_linear = rng.randfn(0.7, 0.15)

func _clickable_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if not game_board.player_can_interact:
		return
	if card_mode == CARD_MODE.HAND:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				card_mode = CARD_MODE.CONTROL
				reparent(game_board.grid_occupiers)
	if card_mode == CARD_MODE.CONTROL:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_released() and not hovered_grid_spaces:
				release_control()

func grid_space_input_event(source: GridSpace, event: InputEvent):
	if not game_board.player_can_interact:
		return
	if card_mode != CARD_MODE.CONTROL:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released():
			var grid_pos: Vector2i = source.grid_position
			if game_board.can_place_here(grid_pos):
				play_card(grid_pos)
			else:
				release_control()

func grid_space_mouse_entered():
	hovered_grid_spaces += 1

func grid_space_mouse_exit():
	hovered_grid_spaces -= 1

func release_control():
	if card_mode != CARD_MODE.CONTROL:
		return
	card_mode = CARD_MODE.HAND
	reparent(player_cards)


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
			await get_tree().create_timer(0.5).timeout
			player_cards.card_played.emit()
		else:
			printerr("WARNING: Attempted to play card that's not in hand ", self)
	else:
		printerr("WARNING: Attempted to play card in invalid position ", grid_position)

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


func _get_move_speed() -> float:
	match card_mode:
		CARD_MODE.CONTROL:
			return 10_000
		CARD_MODE.HAND:
			return 5000
		_:
			return 800

func _process(delta: float) -> void:
	position = position.move_toward(
		get_target_position(),
		delta * _get_move_speed(),
	)

func set_grid_position(grid_position: Vector2i):
	if game_board.can_place_here(grid_position):
		if game_board.card_grid_spaces.get(current_grid_position) == self:
			game_board.card_grid_spaces.erase(current_grid_position)
		current_grid_position = grid_position
		game_board.card_grid_spaces[current_grid_position] = self
	else:
		printerr("WARNING: Attempted to set card position to invalid place ", grid_position)

func push(direction: Vector2i):
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

func _play_sfx():
	_randomise_sfx()
	sfx.play(sfx_start)

func do_card_effect():
	pass

enum EFFECT_TRIGGER {ON_PLAY, ON_CARD_PLAYED, ON_TURN_END, ON_MOVED}

@export var effect_triggers: Array[EFFECT_TRIGGER] = [EFFECT_TRIGGER.ON_TURN_END]

func _effect_should_play(_card_number: int) -> bool:
	return card_mode == CARD_MODE.BOARD and _card_number == card_number

func _animate():
	var tween = get_tree().create_tween()
	tween.tween_property($Artwork, "scale", Vector2.ONE * 1.3, 0.3).set_trans(
		Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Artwork, "rotation", -0.5, 0.3).set_trans(
		Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property($Artwork, "rotation", 0.5, 0.3).set_trans(
		Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Artwork, "rotation", 0, 0.3).set_trans(
		Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property($Artwork, "scale", Vector2.ONE, 0.3).set_trans(
		Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _do_card_effect(_card_number_trigger: int):
	if _effect_should_play(_card_number_trigger):
		_play_sfx()
		_animate()
		do_card_effect()

func on_play_effect():
	if EFFECT_TRIGGER.ON_PLAY in effect_triggers:
		_do_card_effect(card_number)


func on_card_played_effect(_card_number_trigger: int):
	if EFFECT_TRIGGER.ON_CARD_PLAYED in effect_triggers:
		_do_card_effect(_card_number_trigger)

func on_turn_end_effect(_card_number_trigger: int):
	if EFFECT_TRIGGER.ON_TURN_END in effect_triggers:
		_do_card_effect(_card_number_trigger)

func on_moved_effect(_card_number_trigger: int):
	if EFFECT_TRIGGER.ON_MOVED in effect_triggers:
		_do_card_effect(_card_number_trigger)

func save_state() -> Dictionary:
	return {
		"grid_position": current_grid_position,
		"parent": get_parent(),
		"visible": visible,
		"position": position,
		"scale": scale,
		"card_mode": card_mode,
	}

func load_state(state_dict: Dictionary):
	current_grid_position = state_dict["grid_position"]
	reparent(state_dict["parent"])
	visible = state_dict["visible"]
	position = state_dict["position"]
	scale = state_dict["scale"]
	card_mode = state_dict["card_mode"]

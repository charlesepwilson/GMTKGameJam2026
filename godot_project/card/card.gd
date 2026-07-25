class_name Card
extends Node2D

enum CARD_MODE {DECK, HAND, CONTROL, BOARD, DISCARD}

@export var card_number: int = 1
@export var card_name: String = "Card Name"
@onready var number_label: Sprite2D = $Border/Number
@onready var trigger_icon: Sprite2D = $Border/TriggerIcon
@export var current_grid_position: Vector2i = Vector2i.DOWN * 3 + Vector2i.RIGHT
var game_board: GameBoard
var player_cards: PlayerCards

@export var movable: bool = true
@export var starts_on_board: bool = false
@export var should_be_visible: bool = true

var max_move_speed: float = 800
@onready var sprite: Sprite2D = $Border/Artwork

var card_mode: CARD_MODE = CARD_MODE.DECK

@onready var clickable_area: Area2D = $Area2D
@onready var sfx = $AudioStreamPlayer2D
@export var sfx_start: float = 0
var rng = RandomNumberGenerator.new()

var hovered_grid_spaces: int = 0

var number_textures: Dictionary[int, Texture] = {
	1: preload("res://_numbers/1.png"),
	2: preload("res://_numbers/2.png"),
	3: preload("res://_numbers/3.png"),
	4: preload("res://_numbers/4.png"),
	5: preload("res://_numbers/5.png"),
	6: preload("res://_numbers/6.png"),
	7: preload("res://_numbers/7.png"),
	8: preload("res://_numbers/8.png"),
	9: preload("res://_numbers/9.png"),
	10: preload("res://_numbers/10.png"),
}

func _ready() -> void:
	_randomise_sfx()
	if card_number in number_textures:
		number_label.texture = number_textures[card_number]
	trigger_icon.texture = trigger_icons[effect_triggers[0]]
	game_board = find_parent("GameBoard")
	player_cards = game_board.find_child("PlayerCards")
	visible = false
	clickable_area.input_event.connect(_clickable_area_input_event)
	build_tooltips()
	clickable_area.mouse_entered.connect(show_tooltip)
	clickable_area.mouse_exited.connect(hide_tooltip)

	await game_board.ready
	if starts_on_board:
		player_cards.draw_pile.erase(self)
		play_card(current_grid_position, true)
		position = get_target_position()
		if should_be_visible:
			visible = true


func _randomise_sfx():
	sfx.pitch_scale = rng.randf_range(0.85, 1.15)
	sfx.volume_linear = rng.randf_range(0.85, 1.15)

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

func play_card(grid_position: Vector2i, ignore_hand: bool = false):
	if game_board.can_place_here(grid_position):
		if ignore_hand or player_cards.play_card(self):
			card_mode = CARD_MODE.BOARD
			reparent(game_board.grid_occupiers)
			set_grid_position(grid_position)
			var grid_space_size: Vector2 = game_board.grid_visual.get_grid_space_size()
			var texture_size: Vector2 = sprite.texture.get_size()
			scale = min(grid_space_size.x, grid_space_size.y) / max(texture_size.x, texture_size.y) * Vector2.ONE
			on_play_effect()
			await get_tree().create_timer(0.5/Settings.game_speed).timeout
			player_cards.card_played.emit()
		else:
			printerr("WARNING: Attempted to play card that's not in hand ", self)
	else:
		printerr("WARNING: Attempted to play card in invalid position ", grid_position)

@onready var border_sprite_size: Vector2 = $Border.texture.get_size()

func _get_position_offset() -> Vector2:
	return (border_sprite_size * scale / 2) + (Vector2.ONE * 5)

func get_target_position() -> Vector2:
	match card_mode:
		CARD_MODE.BOARD:
			return game_board.get_physical_position(current_grid_position) + _get_position_offset()
		CARD_MODE.HAND:
			return player_cards.get_card_physical_position(self)
		CARD_MODE.CONTROL:
			return game_board.grid_occupiers.get_local_mouse_position()
		_:
			return Vector2(-500, 0)


func _get_move_speed() -> float:
	var s: float
	match card_mode:
		CARD_MODE.CONTROL:
			s = 10_000
		CARD_MODE.HAND:
			s = 5000
		_:
			s = 800
	return s * Settings.game_speed

func _process(delta: float) -> void:
	position = position.move_toward(
		get_target_position(),
		delta * _get_move_speed(),
	)

func set_grid_position(grid_position: Vector2i):
	if not movable and not starts_on_board:
		printerr("WARNING: Tried to move immovable object")
	if game_board.can_place_here(grid_position):
		if game_board.card_grid_spaces.get(current_grid_position) == self:
			game_board.card_grid_spaces.erase(current_grid_position)
		current_grid_position = grid_position
		game_board.card_grid_spaces[current_grid_position] = self
	else:
		printerr("WARNING: Attempted to set card position to invalid place ", grid_position)

func push(direction: Vector2i):
	if not movable:
		return
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

@onready var artwork = $Border/Artwork

@onready var base_artwork_scale: Vector2 = artwork.scale

func animate():
	var tween = get_tree().create_tween()
	tween.tween_property(artwork, "scale", base_artwork_scale * 1.3, 0.3 / Settings.game_speed).set_trans(
		Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(artwork, "rotation", -0.5, 0.3 / Settings.game_speed).set_trans(
		Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(artwork, "rotation", 0.5, 0.3 / Settings.game_speed).set_trans(
		Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(artwork, "rotation", 0, 0.3 / Settings.game_speed).set_trans(
		Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(artwork, "scale", base_artwork_scale, 0.3 / Settings.game_speed).set_trans(
		Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _do_card_effect(_card_number_trigger: int):
	if _effect_should_play(_card_number_trigger):
		_play_sfx()
		animate()
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

@onready var multitooltip: MultiTooltip = $TooltipHolder/MultiTooltip

func _trigger_descriptions(trigger: EFFECT_TRIGGER) -> String:
	match trigger:
		EFFECT_TRIGGER.ON_CARD_PLAYED: return "Activates when anyone enters the Dance Floor"
		EFFECT_TRIGGER.ON_TURN_END: return "Activates when the DJ is clicked"
		_: return "Activates when ..."

func _describe_effect() -> String:
	return ""

var tooltip_scene: PackedScene = preload("res://tooltip/tooltip.tscn")

func build_tooltips():
	var name_label: Tooltip = tooltip_scene.instantiate()
	name_label.tooltip_description = card_name
	multitooltip.add_child(name_label)

	var tooltip_number_label: Tooltip = tooltip_scene.instantiate()
	tooltip_number_label.tooltip_description = "Activates at number {n} in the countdown".format({"n": card_number})
	multitooltip.add_child(tooltip_number_label)

	for trigger in effect_triggers:
		var trigger_tooltip: Tooltip = tooltip_scene.instantiate()
		trigger_tooltip.tooltip_icon = $Border/TriggerIcon.texture
		trigger_tooltip.tooltip_description = _trigger_descriptions(trigger)
		multitooltip.add_child(trigger_tooltip)

	var effect_tooltip: Tooltip = tooltip_scene.instantiate()
	effect_tooltip.tooltip_icon = $Border/EffectIcon.texture
	effect_tooltip.tooltip_description = _describe_effect()
	multitooltip.add_child(effect_tooltip)

func show_tooltip():
	if card_mode in [CARD_MODE.HAND, CARD_MODE.BOARD]:
		multitooltip.show_tooltip()

func hide_tooltip():
	multitooltip.hide_tooltip()

@onready var effect_icon: Sprite2D = $Border/EffectIcon

func _set_icon_direction(m_dir: Vector2i):
	match m_dir.sign():
		Vector2i.RIGHT: effect_icon.rotation_degrees = 0
		Vector2i.DOWN: effect_icon.rotation_degrees = 90
		Vector2i.LEFT: effect_icon.rotation_degrees = 180
		Vector2i.UP: effect_icon.rotation_degrees = 270

var trigger_icons: Dictionary[EFFECT_TRIGGER, Texture] = {
	EFFECT_TRIGGER.ON_CARD_PLAYED: preload("res://card/When played.png"),
	EFFECT_TRIGGER.ON_TURN_END: preload("res://card/On_DJ.png"),
}

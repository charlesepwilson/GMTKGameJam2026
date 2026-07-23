class_name PlayerCards
extends Node2D


var draw_pile: Array[Card] = []
var hand: Array[Card] = []
var discard_pile: Array[Card] = []
var hand_limit: int = 4
@onready var draw_timer: Timer = $Timer

@export var randomise_deck: bool = true
var initial_hand_filled: bool = false

signal failed_to_draw(message: String)

signal card_played()
signal card_drawn()

func _ready():
	for card in find_children("*", "Card", false):
		draw_pile.append(card)
	if randomise_deck:
		draw_pile.shuffle()
	draw_timer.wait_time = 0.1
	draw_timer.timeout.connect(draw_card)

func draw_card():
	if initial_hand_filled:
		draw_timer.wait_time = randfn(2, 0.7)
	if len(hand) >= hand_limit:
		failed_to_draw.emit("Hand is full")
		return
	var top_card = draw_pile.pop_back()
	if top_card != null:
		top_card.add_to_hand()
		hand.push_front(top_card)
		card_drawn.emit()
		if len(hand) >= hand_limit:
			initial_hand_filled = true
	else:
		failed_to_draw.emit("No cards left")

func get_card_physical_position(card: Card) -> Vector2:
	return Vector2.DOWN * hand.find(card) * 200

func play_card(card: Card):
	if card in hand:
		hand.erase(card)
		return true
	return false

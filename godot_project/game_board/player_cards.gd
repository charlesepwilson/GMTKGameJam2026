class_name PlayerCards
extends Node2D


var draw_pile: Array[Card] = []
var hand: Array[Card] = []
var discard_pile: Array[Card] = []

signal failed_to_draw(message: String)

func draw_card():
	print("DRAW_CARD ", hand)
	var top_card = draw_pile.pop_back()
	if top_card != null:
		top_card.add_to_hand()
		hand.append(top_card)
	else:
		failed_to_draw.emit("No cards left")

func get_card_physical_position(card: Card) -> Vector2:
	return Vector2.ZERO  # todo

func play_card(card: Card):
	if card in hand:
		hand.erase(card)
		return true
	return false

class_name FieldEffect
extends Node2D

var consumed: bool = false
@export var starting_position: Vector2i = Vector2i.ZERO

func should_consume_on_activate() -> bool:
	return true

func _apply_effect(card: Card):
	pass

func apply_effect(card: Card):
	_apply_effect(card)
	if should_consume_on_activate():
		consumed = true
		hide()

func save_state() -> Dictionary:
	return {
		"consumed": consumed,
	}

func load_state(state_dict: Dictionary):
	consumed = state_dict["consumed"]
	visible = not consumed

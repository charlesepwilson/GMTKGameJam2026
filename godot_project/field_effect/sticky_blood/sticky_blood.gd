extends FieldEffect

const blood_material: ShaderMaterial = preload("res://field_effect/sticky_blood/blood_material.tres")



func _apply_effect(card: Card):
	card.movable = false
	card.effect_suppressed = true
	card.border_sprite.material = blood_material

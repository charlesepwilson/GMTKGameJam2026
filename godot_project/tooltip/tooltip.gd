class_name Tooltip
extends PanelContainer

var tooltip_icon: Texture
var tooltip_description: String

var fade_seconds: float = 0.2

var tween: Tween

@onready var texture_rect_icon: TextureRect = $MarginContainer/HBoxContainer/Icon
@onready var tooltip_label: Label = $MarginContainer/HBoxContainer/TooltipText

func _ready() -> void:
	texture_rect_icon.texture = tooltip_icon
	tooltip_label.text = tooltip_description
	modulate = Color.TRANSPARENT
	hide()

func show_tooltip():
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(show)
	tween.tween_property(self, "modulate", Color.WHITE, fade_seconds)

func hide_tooltip():
	if tween:
		tween.kill()

	hide_animation()

func hide_animation():
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_seconds)
	tween.tween_callback(hide)

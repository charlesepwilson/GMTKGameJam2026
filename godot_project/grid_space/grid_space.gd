class_name GridSpace
extends Node2D

var grid_position: Vector2i
@onready var texture = $Sprite2D.texture
@onready var area2d: Area2D = $Area2D

func set_grid_space_scale(grid_space_size: Vector2):
	var texture_size = texture.get_size()
	scale = grid_space_size / texture_size

func _ready():
	$Sprite2D.set_instance_shader_parameter("random_seed", randf())
	area2d.input_event.connect(_on_input_event)

signal mouse_released(source: GridSpace, event: InputEvent)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released():
			mouse_released.emit(self, event)

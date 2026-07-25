extends Node2D

var total_grid_x_spaces: int = 5
var total_grid_y_spaces: int = 5

var grid_total_x_size: float = 800
var grid_total_y_size: float = 800
var grid_line_thickness: float = 5

@onready var grid_squares = $GridSquares

var grid_space_scene: PackedScene = preload("res://grid_space/grid_space.tscn")

func get_physical_position(grid_position: Vector2i, with_offset: bool = false) -> Vector2:
	var spacing = get_grid_spacing()
	var physical_x = grid_position.x * spacing.x
	var physical_y = grid_position.y * spacing.y

	var physical_position = Vector2(physical_x, physical_y)
	if with_offset:
		physical_position += spacing / 2
	return physical_position

func physical_position_to_grid_position(physical_position: Vector2) -> Vector2i:
	var spacing = get_grid_spacing()
	var grid_x = physical_position.x / spacing.x
	var grid_y = physical_position.y / spacing.y
	return Vector2i(grid_x, grid_y)

var blocked_coords: Array[Vector2i] = []

func get_grid_spacing() -> Vector2:
	var grid_space_size = get_grid_space_size()
	var grid_x_spacing = grid_space_size.x + grid_line_thickness
	var grid_y_spacing = grid_space_size.y + grid_line_thickness
	return Vector2(grid_x_spacing, grid_y_spacing)

func get_grid_space_size() -> Vector2:
	var grid_space_x_size = (grid_total_x_size / total_grid_x_spaces)
	var grid_space_y_size = (grid_total_y_size / total_grid_y_spaces)
	return Vector2(grid_space_x_size, grid_space_y_size)

func destroy_grid():
	for child in grid_squares.get_children():
		remove_child(child)
		child.queue_free()

func construct_grid():
	destroy_grid()
	for x in total_grid_x_spaces:
		for y in total_grid_y_spaces:
			var grid_pos = Vector2i(x, y)
			if grid_pos not in blocked_coords:
				_make_grid_space(grid_pos)

func _make_grid_space(grid_position: Vector2i):
	var spacing = get_grid_spacing()
	var grid_space = grid_space_scene.instantiate()
	grid_space.grid_position = grid_position
	grid_squares.add_child(grid_space)
	grid_space.position.x = grid_position.x * spacing.x
	grid_space.position.y = grid_position.y * spacing.y
	grid_space.set_grid_space_scale(get_grid_space_size())

@tool
class_name GridData
extends Resource

enum Cell_State { WALKABLE = 0, BLOCKED = 1 }
const INVALID_CELL: Vector2i = Vector2i(-1,-1)

@export var cells: PackedByteArray
@export var grid_dimensions: Vector2i = Vector2i(32,32): 
	set(value):
		if value == grid_dimensions or value.x <= 0 or value.y <= 0:
			return
		var old_dimensions = grid_dimensions
		grid_dimensions = value
		resize_grid(old_dimensions, value)
		grid_dimensions = value
		_resize_bounds()
		emit_changed()
@export var cell_size: float = 1:
	set(value):
		cell_size = value
		_resize_bounds()
		emit_changed()
var bounds: Rect2 = Rect2()

func _init() -> void:
	if !cells.is_empty(): return
	
	cells.resize(grid_dimensions.x * grid_dimensions.y)
	cells.fill(Cell_State.WALKABLE)
	_resize_bounds()

func resize_grid(old_dimensions: Vector2i, new_dimensions: Vector2i) -> void:
	# If only the y axis changes, we can just remove elements from the bottom of the grid
	if new_dimensions.x == old_dimensions.x:
		cells.resize(new_dimensions.x * new_dimensions.y)
		old_dimensions = new_dimensions
		emit_changed()
		return
	
	# Copy the mininum-similar cells between the new and old grids
	var new_cells = PackedByteArray()
	var min_x = min(old_dimensions.x, new_dimensions.x)
	var min_y = min(old_dimensions.y, new_dimensions.y)
	
	var row_padding: PackedByteArray = PackedByteArray()
	row_padding.resize(max(0, new_dimensions.x - old_dimensions.x))
	row_padding.fill(Cell_State.WALKABLE)
	
	for y in range(min_y):
		var old_row_start = y * old_dimensions.x
		
		var row_chunk = cells.slice(old_row_start, old_row_start + min_x)
		row_chunk.append_array(row_padding)
		new_cells.append_array(row_chunk)
	
	var bottom_padding: PackedByteArray = PackedByteArray()
	bottom_padding.resize(new_dimensions.x * max(0, new_dimensions.y - old_dimensions.y))
	bottom_padding.fill(Cell_State.WALKABLE)
	new_cells.append_array(bottom_padding)
	
	cells = new_cells
	emit_changed()

func _resize_bounds() -> void:
	bounds = Rect2(Vector2.ZERO, grid_dimensions * cell_size)

func world_to_grid(coords: Vector2):
	var x = int(floor(coords.x / cell_size))
	var y = int(floor(coords.y / cell_size))
	
	return Vector2i(x, y)

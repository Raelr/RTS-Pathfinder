@tool
class_name PaintVisualiser
extends Node2D

var unwalkable_cells: Dictionary[Vector2i, int]:
	set(value):
		if unwalkable_cells == value: return
		queue_redraw() 

var rects: Array[Rect2]

func paint_unwalkable_cells(target_cells: Array[Vector2i], cell_size: float):
	for cell in target_cells:
		add_unwalkable_cell(cell, cell_size)
	print("PAINTING UNWALKABLE CELLS")
	redraw(cell_size)

func paint_cell(cell_location: Vector2i, cell_size: float, mode: RTSGridBuilder.Brush_Mode):
	if mode == RTSGridBuilder.Brush_Mode.UNWALKABLE: add_unwalkable_cell(cell_location, cell_size)
	if mode == RTSGridBuilder.Brush_Mode.CLEAR: clear_unwalkable_cell(cell_location, cell_size)
	redraw(cell_size)

func add_unwalkable_cell(cell_location: Vector2i, cell_size: float):
	if cell_location == GridData.INVALID_CELL or unwalkable_cells.has(cell_location): return
	var rects_idx = clamp(rects.size()-1, 0, rects.size())
	unwalkable_cells[cell_location] = rects_idx

func clear_unwalkable_cell(cell_location: Vector2i, cell_size: float):
	if cell_location == GridData.INVALID_CELL or not unwalkable_cells.has(cell_location): return
	unwalkable_cells.erase(cell_location)

func redraw(cell_size: float):
	var old_rects = rects
	rects.clear()
	for cell in unwalkable_cells.keys():
		rects.append(Rect2(Vector2(cell * cell_size), Vector2(cell_size, cell_size)))
	queue_redraw()

func _draw() -> void:
	for rect in rects:
		draw_rect(rect, Color.RED, false)

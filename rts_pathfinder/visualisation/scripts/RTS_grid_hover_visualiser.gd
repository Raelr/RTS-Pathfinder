@tool
class_name HoverVisualiser
extends Node2D

var hovered_cell: Vector2i = Vector2i(-1, -1):
	set(value):
		if hovered_cell == value: return
		hovered_cell = value
		queue_redraw()

var cell_size: float = 1.0:
	set(value):
		if cell_size == value: return
		cell_size = value
		queue_redraw()

func _draw() -> void:
	if (hovered_cell != GridData.INVALID_CELL):
		draw_rect(Rect2(Vector2(hovered_cell * cell_size), Vector2(cell_size, cell_size)), Color.GREEN, false)

@tool
class_name PathVisualiser
extends Node2D

var source_cell: Vector2i = Vector2i(-1,-1):
	set(value):
		if source_cell == value: return
		source_cell = value
		clear()
		queue_redraw()

var active_path: PackedVector2Array:
	set(value):
		if active_path == value: return
		clear()
		active_path = value
		queue_redraw()

var cell_size: float = 1:
	set(value):
		if cell_size == value: return
		clear()
		cell_size = value
		queue_redraw()

func _draw() -> void:
	
	if source_cell == Vector2i(-1,-1): return
	
	draw_rect(Rect2(Vector2(source_cell * cell_size), Vector2(cell_size, cell_size)), Color.BLUE, true)
	
	if active_path.size() < 2: return
	
	var offset = cell_size * 0.5
	var points: PackedVector2Array = PackedVector2Array()
	points.resize(active_path.size())
	
	for i in active_path.size():
		var p = active_path[i]
		points[i] = Vector2(p.x * cell_size + offset, p.y * cell_size + offset)
		
	draw_polyline(points, Color.GREEN, 0.05, true)

func clear() -> void:
	active_path.clear()

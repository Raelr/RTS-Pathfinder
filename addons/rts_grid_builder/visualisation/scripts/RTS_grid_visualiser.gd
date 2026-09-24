@tool
class_name GridVisualiser
extends Node2D

@export var grid: GridData

@onready var hover_visualiser: HoverVisualiser = $RTS_HoverVisualiser
@onready var paint_visualiser: PaintVisualiser = $RTS_PaintVisualiser

var hovered_cell: Vector2i = Vector2i(-1,-1):
	set(value):
		if not hover_visualiser: return
		hovered_cell = value
		hover_visualiser.hovered_cell = value

func on_cell_clicked(cell: Vector2i, brush_mode: RTSGridBuilder.Brush_Mode) -> void:
	if not paint_visualiser or brush_mode == RTSGridBuilder.Brush_Mode.NONE: return
	paint_visualiser.paint_cell(cell, grid.cell_size, brush_mode)

func set_cells_unwalkable(cells: Array[Vector2i], cell_size: float) -> void:
	if not paint_visualiser: return
	paint_visualiser.paint_unwalkable_cells(cells, cell_size)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid.changed.connect(redraw_grid)
	redraw_grid()

func redraw_grid():
	queue_redraw()
	if not hover_visualiser: return 
	hover_visualiser.cell_size = grid.cell_size

func _draw():
	if not grid or not grid.grid_dimensions: return
	var lines: PackedVector2Array = []
	var dimensions = grid.grid_dimensions
	var cell_dimensions = grid.cell_size
	
	for x in range(dimensions.x + 1):
		var x_pos = x * cell_dimensions
		lines.append(Vector2(x_pos, 0))
		lines.append(Vector2(x_pos, dimensions.y * cell_dimensions))
	
	for y in range(dimensions.y + 1):
		var y_pos = y * cell_dimensions
		lines.append(Vector2(0, y_pos))
		lines.append(Vector2(dimensions.x * cell_dimensions, y_pos))
	
	draw_multiline(lines, Color.WHITE)

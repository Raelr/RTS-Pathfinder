@tool
class_name RTS_GridBuilderDockContainer
extends MarginContainer

# options container signals
signal on_new_grid(path: String)
signal on_grid_saved(path: String)
signal on_grid_loaded(path: String)

# Body container signals
signal on_refreshed

# Brush Container signals
signal on_brush_selected(mode: RTSGridBuilder.Brush_Mode)

func _init(grid: GridData = null, brush_mode: RTSGridBuilder.Brush_Mode = RTSGridBuilder.Brush_Mode.NONE):
	build(grid, brush_mode)

func build(grid: GridData, brush_mode: RTSGridBuilder.Brush_Mode) -> void:
	var body: HBoxContainer = HBoxContainer.new()
	
	const margin = RTSGridDockTheme.MARGIN
	
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("margin_left", margin)
	add_theme_constant_override("margin_top", margin)
	add_theme_constant_override("margin_right", margin)
	add_theme_constant_override("margin_bottom", margin) 
	
	var left_side_options: RTS_GridBuilderDockOptions = RTS_GridBuilderDockOptions.new()
	left_side_options.on_grid_load_requested.connect(func(path: String): on_grid_loaded.emit(path))
	left_side_options.on_grid_save_requested.connect(func(path: String): on_grid_saved.emit(path))
	left_side_options.on_new_grid_requested.connect(func(path: String): on_new_grid.emit(path))
	
	var separator: VSeparator = VSeparator.new()
	var style = RTSGridDockTheme.get_line_style()
	style.vertical = true
	separator.add_theme_stylebox_override("separator", style)
	
	var right_side_body = RTS_GridBuilderDockBodyContainer.new(grid, brush_mode)
	right_side_body.on_refreshed.connect(on_refreshed.emit)
	right_side_body.on_brush_mode_selected.connect(on_brush_selected.emit)
	
	body.add_child(left_side_options)
	body.add_child(separator)
	body.add_child(right_side_body)
	add_child(body)

func refresh(grid: GridData = null, brush_mode: RTSGridBuilder.Brush_Mode = RTSGridBuilder.Brush_Mode.NONE) -> void:
	for child in get_children():
		child.queue_free()
	build(grid, brush_mode)

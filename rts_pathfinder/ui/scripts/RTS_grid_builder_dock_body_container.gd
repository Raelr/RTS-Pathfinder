@tool
class_name RTS_GridBuilderDockBodyContainer
extends VBoxContainer

signal on_refreshed
signal on_brush_mode_selected(mode: RTSGridBuilder.Brush_Mode)

func _init(grid: GridData =  null, mode: RTSGridBuilder.Brush_Mode = RTSGridBuilder.Brush_Mode.NONE):
	build(mode, grid)

func build(mode: RTSGridBuilder.Brush_Mode, grid: GridData) -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Header Container
	var header: RTS_GridBuilderDockHeaderContainer = RTS_GridBuilderDockHeaderContainer.new()
	header.on_refreshed.connect(on_refreshed.emit)
	
	var separator: HSeparator = HSeparator.new()
	separator.add_theme_stylebox_override("separator", RTSGridDockTheme.get_line_style())
	
	# Editor title + Resource picker
	var resource_picker = RTS_GridBuilderDockSelectedGridContainer.new(grid)
	
	# Paint brushes 
	
	var brush_picker = RTS_GridBuilderDockBrushContainer.new(mode)
	brush_picker.on_brush_selected.connect(on_brush_mode_selected.emit)
	
	add_child(header)
	add_child(separator)
	add_child(resource_picker)
	add_child(brush_picker)

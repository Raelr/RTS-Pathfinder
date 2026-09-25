@tool
class_name RTS_GridBuilderDockBrushContainer
extends HBoxContainer

signal on_brush_selected(mode: RTSGridBuilder.Brush_Mode)

func _init(brush_mode: RTSGridBuilder.Brush_Mode = RTSGridBuilder.Brush_Mode.NONE) -> void:
	build(brush_mode)
	
func build(brush_mode: RTSGridBuilder.Brush_Mode):
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var brush_label: Label = Label.new()
	var mode = "NONE" if brush_mode == 0 else "OBSTACLE" if brush_mode == 1 else "CLEAR"
	brush_label.text = "Paint Mode: %s" % mode
	
	var unwalkable_brush_button: Button = Button.new()
	unwalkable_brush_button.icon = EditorInterface.get_editor_theme()\
		.get_icon("NavigationObstacle2D", "EditorIcons")
	unwalkable_brush_button.tooltip_text = "Paint obstacles"
	unwalkable_brush_button.pressed.connect(func(): 
		brush_mode_selected(RTSGridBuilder.Brush_Mode.UNWALKABLE))
	
	var walkable_brush_button: Button = Button.new()
	walkable_brush_button.icon = EditorInterface.get_editor_theme()\
		.get_icon("Clear", "EditorIcons")
	walkable_brush_button.tooltip_text = "Clear obstacles"
	walkable_brush_button.pressed.connect(func(): 
		brush_mode_selected(RTSGridBuilder.Brush_Mode.CLEAR))
		
	var close_brush_button: Button = Button.new()
	close_brush_button.icon = EditorInterface.get_editor_theme()\
		.get_icon("GuiClose", "EditorIcons")
	close_brush_button.tooltip_text = "Stop painting (right click)"
	close_brush_button.pressed.connect(func(): 
		brush_mode_selected(RTSGridBuilder.Brush_Mode.NONE))
	
	add_child(brush_label)
	add_child(unwalkable_brush_button)
	add_child(walkable_brush_button)
	add_child(close_brush_button)

func brush_mode_selected(mode: RTSGridBuilder.Brush_Mode) -> void:
	on_brush_selected.emit(mode)

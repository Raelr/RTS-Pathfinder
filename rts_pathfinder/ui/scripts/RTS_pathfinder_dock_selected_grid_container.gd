@tool
class_name RTS_GridBuilderDockSelectedGridContainer
extends HBoxContainer

func _init(grid: GridData = null) -> void:
	build(grid)

func build(grid: GridData = null) -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var label: Label = Label.new()
	label.text = "Current Grid"
	
	var resource_display: EditorResourcePicker = EditorResourcePicker.new()
	resource_display.base_type = "Resource"
	resource_display.edited_resource = grid
	resource_display.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	add_child(label)
	add_child(resource_display)

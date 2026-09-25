@tool
class_name RTS_GridBuilderDockHeaderContainer

extends HBoxContainer

signal on_refreshed

func _ready() -> void:
	build()

func build() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", RTSGridDockTheme.MARGIN)
	var label: Label = Label.new()
	label.text = "Grid Builder"
	
	var refresh_button: Button = Button.new()
	refresh_button.text = "Refresh"
	refresh_button.icon = EditorInterface.get_editor_theme().get_icon("RotateLeft", "EditorIcons")
	refresh_button.pressed.connect(on_refreshed.emit)
	
	var separator = Control.new()
	separator.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	add_child(label)
	add_child(separator)
	add_child(refresh_button)

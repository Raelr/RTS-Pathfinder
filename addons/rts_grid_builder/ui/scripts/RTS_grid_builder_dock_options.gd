@tool
class_name RTS_GridBuilderDockOptions
extends VBoxContainer

var file_dialogue: EditorFileDialog = null

signal on_grid_save_requested(file: String)
signal on_new_grid_requested(file: String)
signal on_grid_load_requested(file: String)

enum Dialogue_State { NEW = 0, SAVE = 1, LOAD = 2, NONE = 3 }
var dialogue_state: Dialogue_State = Dialogue_State.NONE

func _ready() -> void:
	build()

func build() -> void:
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var new_grid_button: Button = Button.new()
	new_grid_button.text = "New grid"
	new_grid_button.icon = EditorInterface.get_editor_theme().get_icon("New", "EditorIcons")
	new_grid_button.tooltip_text = "Create a new grid"
	new_grid_button.pressed.connect(func(): _on_save_grid_selected(Dialogue_State.NEW))
	
	var load_grid_button: Button = Button.new()
	load_grid_button.text = "Load grid"
	load_grid_button.icon = EditorInterface.get_editor_theme().get_icon("Folder", "EditorIcons")
	load_grid_button.tooltip_text = "Load a grid resource"
	load_grid_button.pressed.connect(_on_load_grid_selected)
	
	var save_grid_button: Button = Button.new()
	save_grid_button.text = "Save grid"
	save_grid_button.icon = EditorInterface.get_editor_theme().get_icon("Save", "EditorIcons")
	save_grid_button.tooltip_text = "Save a grid to memory"
	save_grid_button.pressed.connect(func(): _on_save_grid_selected(Dialogue_State.SAVE))
	
	file_dialogue = EditorFileDialog.new()
	file_dialogue.size = Vector2i(2000, 1000)
	file_dialogue.add_filter("*.tres", "Godot Resource")
	file_dialogue.file_selected.connect(_on_file_selected)
	
	add_child(new_grid_button)
	add_child(load_grid_button)
	add_child(save_grid_button)
	add_child(file_dialogue)

func _on_save_grid_selected(mode: Dialogue_State) -> void:
	file_dialogue.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	file_dialogue.title = "Choose location to save grid..."
	dialogue_state = mode
	file_dialogue.popup_centered_ratio(0.5)

func _on_load_grid_selected() -> void:
	file_dialogue.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	file_dialogue.title = "Choose grid to load..."
	dialogue_state = Dialogue_State.LOAD
	file_dialogue.popup_centered_ratio(0.5)

func _on_file_selected(path: String) -> void:
	var target_signal = on_new_grid_requested if dialogue_state == Dialogue_State.NEW \
	else on_grid_save_requested if dialogue_state == Dialogue_State.SAVE \
	else on_grid_load_requested
	
	target_signal.emit(path)
	
	dialogue_state = Dialogue_State.NONE

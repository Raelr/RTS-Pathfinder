@tool
extends EditorPlugin
class_name RTSGridBuilder

var dock: RTS_GridBuilderDockContainer = null
enum Brush_Mode { NONE = 0, UNWALKABLE = 1, CLEAR = 2}
var active_visualiser: GridVisualiser = null
var active_grid: GridData = null
var brush_mode: int = Brush_Mode.NONE

func _enter_tree() -> void:
	initialise_ui()
	scene_changed.connect(_on_scene_changed)

func _exit_tree() -> void:
	if not dock: return
	
	remove_control_from_docks(dock)
	dock.queue_free()

func initialise_ui() -> void:
	dock = RTS_GridBuilderDockContainer.new()
	dock.name = "RTS Grid Builder"
	dock.on_new_grid.connect(_create_new_grid)
	dock.on_grid_saved.connect(_save_grid)
	dock.on_grid_loaded.connect(_load_grid)
	dock.on_refreshed.connect(_refresh_ui)
	dock.on_brush_selected.connect(_set_brush_mode)
	
	add_control_to_dock(EditorPlugin.DOCK_SLOT_BOTTOM, dock)

func _refresh_ui() -> void:
	if not dock: return
	dock.refresh(active_grid, brush_mode)

func _create_new_grid(file: String) -> void:
	var file_name: String = file
	
	var new_grid = GridData.new()
	
	var grid_exists = FileAccess.file_exists(file_name)
	ResourceSaver.save(new_grid, file_name)
	
	new_grid.take_over_path(file_name)
	new_grid.resource_name = file_name.get_file()
	
	active_grid = new_grid
	
	if grid_exists: return
	
	_create_visualiser(new_grid)

func _save_grid(file: String) -> void:
	var file_name: String = file
	
	if not FileAccess.file_exists(file_name):
		printerr("%s does not exist!" % file)
		return
	
	ResourceSaver.save(active_grid, file_name)

func _load_grid(file: String) -> void:
	var loaded_grid: GridData = load(file)
	
	if not loaded_grid: 
		printerr("Failed to load grid: ", file)
		return
	
	if not active_grid == loaded_grid:
		_create_visualiser(loaded_grid)
	
	active_grid = loaded_grid
	_on_grid_loaded(active_visualiser, loaded_grid)

func _on_grid_loaded(visualiser: GridVisualiser, gridData: GridData):
	if not active_visualiser: return
	
	var obstacles: Array[Vector2i]
	for y in gridData.grid_dimensions.y:
		for x in gridData.grid_dimensions.x:
			var idx = y * gridData.grid_dimensions.y + x
			if gridData.cells[idx] == 1: 
				obstacles.append(Vector2i(x, y))
	visualiser.set_cells_unwalkable(obstacles, gridData.cell_size)

func _create_visualiser(grid: GridData) -> void:
	var scene_root = EditorInterface.get_edited_scene_root()
	
	var visualiser : GridVisualiser = load("res://addons/rts_grid_builder/visualisation/rts_grid_visualiser.tscn").instantiate()
	visualiser.grid = grid
	scene_root.add_child(visualiser)
	visualiser.owner = scene_root
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(visualiser)
	active_visualiser = visualiser

func _handles(object: Object) -> bool:
	return object is GridVisualiser

func _edit(object: Object) -> void:
	var previous_visualiser = active_visualiser
	active_visualiser = object if object is GridVisualiser else null
	
	active_grid = null if active_visualiser == null else active_visualiser.grid
	
	if previous_visualiser != active_visualiser:
		_refresh_ui()

func _set_brush_mode(mode: Brush_Mode) -> void:
	brush_mode = mode
	_refresh_ui()

func _on_scene_changed(root: Node) -> void:
	if not root: return
	
	var visualisers = root.find_children("*", "GridVisualiser", true, false) as Array[GridVisualiser]
	
	if not visualisers or visualisers.is_empty(): return
	
	active_visualiser = visualisers.front()
	active_grid = active_visualiser.grid
	
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(active_visualiser)
	
	_refresh_ui()
	
	for visualiser in visualisers:
		_on_grid_loaded(visualiser, visualiser.grid)
	

func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if not active_visualiser or not active_visualiser.grid or not active_grid: return false
	if event is not InputEventMouseMotion and event is not InputEventMouseButton: return false
	
	var local_pos = active_visualiser.get_local_mouse_position()
	
	if not active_grid.bounds.has_point(local_pos): 
		active_visualiser.hovered_cell = GridData.INVALID_CELL
		return brush_mode != Brush_Mode.NONE
	
	var cell = active_grid.world_to_grid(local_pos)
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and brush_mode != Brush_Mode.NONE:
		var index = cell.y * active_grid.grid_dimensions.x + cell.x
		active_grid.cells[index] = 0 if brush_mode == 2 else 1
		active_visualiser.on_cell_clicked(cell, brush_mode)
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and brush_mode != Brush_Mode.NONE:
		brush_mode = Brush_Mode.NONE
		_refresh_ui()
	
	active_visualiser.hovered_cell = cell
	
	return true
		
	

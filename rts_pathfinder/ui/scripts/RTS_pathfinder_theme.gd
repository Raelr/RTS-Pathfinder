class_name RTSGridDockTheme
extends RefCounted

const MARGIN: int = 20
const LINE_COLOR: Color = Color(0.4, 0.4, 0.4, 1.0)
const LINE_THICKNESS: int = 1

static func get_line_style() -> StyleBoxLine:
	var style = StyleBoxLine.new()
	style.color = LINE_COLOR
	style.thickness = 1
	return style

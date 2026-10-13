class_name ScreenFade
extends CanvasLayer

# Fundido oscuro reutilizable. Aparece por encima de la interfaz (CanvasLayer)
# y se usa tanto para la entrada de cada pantalla como para cambiar de escena.

var _rect: ColorRect
var _busy := false


func _init() -> void:
	layer = 128
	_rect = ColorRect.new()
	_rect.color = Color(0, 0, 0, 1)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.anchor_left = 0.0
	_rect.anchor_top = 0.0
	_rect.anchor_right = 1.0
	_rect.anchor_bottom = 1.0
	_rect.offset_left = 0.0
	_rect.offset_top = 0.0
	_rect.offset_right = 0.0
	_rect.offset_bottom = 0.0
	add_child(_rect)


func _ready() -> void:
	fade_in()


func fade_in(duration: float = 0.35) -> void:
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.color.a = 1.0
	var t := create_tween()
	t.tween_property(_rect, "color:a", 0.0, duration)


func change_scene(path: String, duration: float = 0.28) -> Error:
	if _busy:
		return ERR_BUSY
	_busy = true
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var t := create_tween()
	t.tween_property(_rect, "color:a", 1.0, duration)
	await t.finished
	var error := get_tree().change_scene_to_file(path)
	if error != OK:
		_busy = false
		fade_in()
	return error

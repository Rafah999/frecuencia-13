class_name F13Button
extends Button

# Botón coherente con Frecuencia 13: panel oscuro translúcido, borde frío,
# brillo/escala al pasar el cursor y una interferencia breve al enfocar.

var _scan: ColorRect
var _highlighted := false


func _init() -> void:
	custom_minimum_size = Vector2(0, 32)
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	add_theme_font_size_override("font_size", 13)
	_apply_style()


func _apply_style() -> void:
	add_theme_stylebox_override("normal", _sb(Color(0.03, 0.045, 0.055, 0.60), F13Style.BORDER))
	add_theme_stylebox_override("hover", _sb(Color(0.06, 0.10, 0.11, 0.85), F13Style.BORDER_HOT))
	add_theme_stylebox_override("pressed", _sb(Color(0.02, 0.03, 0.04, 0.95), F13Style.CYAN_DIM))
	add_theme_stylebox_override("focus", _sb(Color(0, 0, 0, 0), F13Style.ALARM))
	add_theme_stylebox_override("disabled", _sb(Color(0.03, 0.03, 0.03, 0.40), Color(0.3, 0.3, 0.3, 0.3)))
	add_theme_color_override("font_color", F13Style.INK_DIM)
	add_theme_color_override("font_hover_color", Color(1, 1, 1))
	add_theme_color_override("font_pressed_color", F13Style.CYAN)
	add_theme_color_override("font_focus_color", F13Style.CYAN)
	add_theme_color_override("font_disabled_color", F13Style.INK_FAINT)


func _sb(bg: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(2)
	sb.content_margin_left = 14.0
	sb.content_margin_right = 14.0
	sb.content_margin_top = 7.0
	sb.content_margin_bottom = 7.0
	return sb


func _ready() -> void:
	mouse_entered.connect(_highlight)
	mouse_exited.connect(_unhighlight)
	focus_entered.connect(_highlight)
	focus_exited.connect(_unhighlight)
	resized.connect(_sync_scan)
	_build_scan()


func _build_scan() -> void:
	_scan = ColorRect.new()
	_scan.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scan.color = Color(F13Style.CYAN.r, F13Style.CYAN.g, F13Style.CYAN.b, 0.0)
	add_child(_scan)
	_sync_scan()


func _sync_scan() -> void:
	if _scan == null:
		return
	_scan.position = Vector2(0, -4)
	_scan.size = Vector2(size.x, 2)
	pivot_offset = size * 0.5


func _highlight() -> void:
	if _highlighted:
		return
	_highlighted = true
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(self, "modulate", Color(1.12, 1.15, 1.18, 1.0), 0.10)
	t.tween_property(self, "scale", Vector2(1.03, 1.03), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_interference()


func _unhighlight() -> void:
	_highlighted = false
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.12)
	t.tween_property(self, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _interference() -> void:
	if _scan == null:
		return
	_scan.position = Vector2(0, -4)
	_scan.color.a = 0.0
	var t := create_tween()
	t.tween_property(_scan, "position:y", size.y + 2.0, 0.16)
	t.parallel().tween_property(_scan, "color:a", 0.55, 0.03)
	t.tween_property(_scan, "color:a", 0.0, 0.06)

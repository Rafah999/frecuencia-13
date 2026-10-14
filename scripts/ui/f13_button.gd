class_name F13Button
extends Button

# Botón coherente con Frecuencia 13: panel grafito translúcido, borde frío,
# acento lateral al pasar el cursor, brillo sutil y una interferencia breve.
# El tono PRIMARY se reserva para la acción principal de cada pantalla.

enum Tone { DEFAULT, PRIMARY, DANGER }

@export var tone: Tone = Tone.DEFAULT:
	set(value):
		tone = value
		_apply_style()

var _accent: ColorRect
var _scan: ColorRect
var _highlighted := false


func _init() -> void:
	custom_minimum_size = Vector2(0, 30)
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	add_theme_font_size_override("font_size", 12)
	add_theme_constant_override("outline_size", 0)
	_apply_style()


func _ready() -> void:
	mouse_entered.connect(_highlight)
	mouse_exited.connect(_unhighlight)
	focus_entered.connect(_highlight)
	focus_exited.connect(_unhighlight)
	resized.connect(_sync_children)
	_build_accent()
	_build_scan()
	_apply_style()


func _apply_style() -> void:
	var normal_bg := Color(0.086, 0.062, 0.055, 0.55)
	var normal_border := F13Style.BORDER
	var normal_text := F13Style.INK_DIM
	var hover_bg := Color(0.165, 0.098, 0.082, 0.82)
	var hover_border := F13Style.BORDER_HOT
	var hover_text := F13Style.INK
	var pressed_bg := Color(0.043, 0.031, 0.028, 0.95)
	var pressed_border := F13Style.EMBER_DIM
	var focus_border := F13Style.EMBER

	match tone:
		Tone.PRIMARY:
			normal_bg = Color(0.360, 0.176, 0.086, 0.82)
			normal_border = F13Style.AMBER
			normal_text = F13Style.INK
			hover_bg = Color(0.480, 0.250, 0.118, 0.92)
			hover_border = Color(0.960, 0.640, 0.340, 0.95)
			hover_text = Color(1.0, 0.960, 0.910)
			pressed_bg = Color(0.280, 0.130, 0.058, 0.98)
			pressed_border = Color(0.960, 0.640, 0.340, 0.95)
			focus_border = F13Style.AMBER
		Tone.DANGER:
			normal_bg = Color(0.150, 0.062, 0.055, 0.72)
			normal_border = Color(0.722, 0.227, 0.212, 0.60)
			normal_text = Color(0.880, 0.680, 0.640)
			hover_bg = Color(0.260, 0.092, 0.078, 0.92)
			hover_border = F13Style.ALARM
			hover_text = Color(1.0, 0.860, 0.820)
			pressed_bg = Color(0.120, 0.040, 0.036, 0.98)
			pressed_border = F13Style.ALARM
			focus_border = F13Style.ALARM

	add_theme_stylebox_override("normal", _sb(normal_bg, normal_border))
	add_theme_stylebox_override("hover", _sb(hover_bg, hover_border))
	add_theme_stylebox_override("pressed", _sb(pressed_bg, pressed_border))
	add_theme_stylebox_override("focus", _sb(Color(0, 0, 0, 0), focus_border))
	add_theme_stylebox_override("disabled", _sb(Color(0.06, 0.05, 0.045, 0.35), Color(0.34, 0.29, 0.27, 0.30)))
	add_theme_color_override("font_color", normal_text)
	add_theme_color_override("font_hover_color", hover_text)
	add_theme_color_override("font_pressed_color", Color(1.0, 0.760, 0.560))
	add_theme_color_override("font_focus_color", hover_text)
	add_theme_color_override("font_disabled_color", F13Style.INK_FAINT)

	if _accent != null:
		_accent.color = _accent_color()


func _accent_color() -> Color:
	match tone:
		Tone.PRIMARY:
			return F13Style.AMBER
		Tone.DANGER:
			return F13Style.ALARM
		_:
			return F13Style.EMBER


func _sb(bg: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(2)
	sb.content_margin_left = 15.0
	sb.content_margin_right = 15.0
	sb.content_margin_top = 7.0
	sb.content_margin_bottom = 7.0
	return sb


func _build_accent() -> void:
	_accent = ColorRect.new()
	_accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_accent.color = _accent_color()
	_accent.modulate.a = 0.0
	add_child(_accent)
	_sync_children()


func _build_scan() -> void:
	_scan = ColorRect.new()
	_scan.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scan.color = Color(F13Style.EMBER.r, F13Style.EMBER.g, F13Style.EMBER.b, 0.0)
	add_child(_scan)
	_sync_children()


func _sync_children() -> void:
	pivot_offset = size * 0.5
	if _accent != null:
		_accent.position = Vector2(1, 4)
		_accent.size = Vector2(2, max(size.y - 8.0, 0.0))
	if _scan != null:
		_scan.position = Vector2(0, -4)
		_scan.size = Vector2(size.x, 2)


func _highlight() -> void:
	if _highlighted:
		return
	_highlighted = true
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(self, "modulate", Color(1.08, 1.10, 1.12, 1.0), 0.10)
	t.tween_property(self, "scale", Vector2(1.015, 1.015), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if _accent != null:
		t.tween_property(_accent, "modulate:a", 0.9, 0.12)
	_interference()


func _unhighlight() -> void:
	_highlighted = false
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.12)
	t.tween_property(self, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if _accent != null:
		t.tween_property(_accent, "modulate:a", 0.0, 0.12)


func _interference() -> void:
	if _scan == null:
		return
	_scan.position = Vector2(0, -4)
	_scan.color.a = 0.0
	var t := create_tween()
	t.tween_property(_scan, "position:y", size.y + 2.0, 0.18)
	t.parallel().tween_property(_scan, "color:a", 0.40, 0.03)
	t.tween_property(_scan, "color:a", 0.0, 0.07)

extends Node

# =========================================================
# FRECUENCIA 13 — Pantalla de carga / intro
# Se construye por código con el estilo F13 y las mismas
# animaciones que el resto de menús (viñeta, scanlines,
# interferencia ocasional y fundido).
# =========================================================

const MAIN_MENU_SCENE := "res://scenes/menu/MainMenu.tscn"
const HOLD_TIME := 3.2

var _title: Label
var _subtitle: Label
var _fade: ScreenFade

var _dots := 0
var _dots_t := 0.0
var _running := true


func _ready() -> void:
	_build()
	await _play_intro()
	await _fade.change_scene(MAIN_MENU_SCENE)


func _build() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = F13Style.BG_NIGHT
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(bg)

	# Viñeta, scanlines e interferencia ambiental (por debajo del texto).
	root.add_child(F13Overlay.new())

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(center)

	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 12)
	center.add_child(col)

	_title = _make_title("FRECUENCIA 13")
	col.add_child(_title)

	var sep := F13Style.separator()
	sep.custom_minimum_size = Vector2(170, 1)
	sep.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(sep)

	_subtitle = F13Style.caption("SINTONIZANDO SEÑAL", 11, F13Style.INK_DIM)
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_subtitle)

	# Interferencia ocasional que afecta a TODA la pantalla.
	root.add_child(F13Overlay.new(F13Overlay.Layer.INTERFERENCE))

	_fade = ScreenFade.new()
	add_child(_fade)


func _make_title(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var base := SystemFont.new()
	base.font_names = PackedStringArray(
		["Consolas", "Cascadia Mono", "Lucida Console", "Courier New", "monospace"]
	)
	var font := FontVariation.new()
	font.base_font = base
	font.spacing_glyph = 6

	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", 34)
	label.add_theme_color_override("font_color", F13Style.EMBER)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.65))
	label.add_theme_constant_override("outline_size", 3)
	label.add_theme_color_override(
		"font_shadow_color",
		Color(F13Style.EMBER.r, F13Style.EMBER.g, F13Style.EMBER.b, 0.35)
	)
	label.add_theme_constant_override("shadow_outline_size", 8)
	return label


func _animate_in() -> void:
	if _title == null or _subtitle == null:
		return
	_title.modulate.a = 0.0
	_subtitle.modulate.a = 0.0


func _play_intro() -> void:
	_animate_in()
	await get_tree().create_timer(0.25).timeout

	# Encendido tipo CRT: parpadeo breve y luego estable.
	var flicker := create_tween()
	flicker.tween_property(_title, "modulate:a", 1.0, 0.05)
	flicker.tween_property(_title, "modulate:a", 0.2, 0.04)
	flicker.tween_property(_title, "modulate:a", 1.0, 0.10)
	flicker.tween_property(_subtitle, "modulate:a", 1.0, 0.30)

	# Respiración lenta del título mientras "carga".
	var pulse := create_tween().set_loops()
	pulse.tween_property(_title, "modulate:a", 0.78, 1.1).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(_title, "modulate:a", 1.0, 1.1).set_trans(Tween.TRANS_SINE)

	await get_tree().create_timer(3.0).timeout


func _process(delta: float) -> void:
	if _subtitle == null:
		return
	_dots_t += delta
	if _dots_t >= 0.4:
		_dots_t = 0.0
		_dots = (_dots + 1) % 4
		_subtitle.text = "SINTONIZANDO SEÑAL" + ".".repeat(_dots)

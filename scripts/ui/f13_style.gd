class_name F13Style
extends RefCounted

# =========================================================
# FRECUENCIA 13 — Hoja de estilo de interfaz
# Horreor psicológico / estación de radio analógica abandonada.
#
# Paleta oscura, industrial y CÁLIDA: la iluminación de la
# estación tira a rojo y ámbar. El óxido/ascua (rojo) es el
# acento principal; el ámbar marca la acción primaria; el cian
# queda como contrapunto frío muy escaso. Texto siempre legible.
# =========================================================

# --- Paleta base -----------------------------------------
const BG_NIGHT := Color(0.043, 0.031, 0.028)      # #0B0807 negro cálido
const GRAPHITE := Color(0.086, 0.062, 0.055)      # #160F0E grafito cálido
const SURFACE := Color(0.153, 0.110, 0.098)       # #271C19 superficie cálida

const CYAN := Color(0.435, 0.682, 0.706)          # #6FAEB4 cian técnico (escaso)
const CYAN_DIM := Color(0.298, 0.463, 0.486)
const CYAN_SIGNAL := Color(0.553, 0.867, 0.878)   # #8DDDE0 señal (contraste frío)
const ALARM := Color(0.722, 0.227, 0.212)         # #B83A36 alarma
const AMBER := Color(0.784, 0.475, 0.243)         # #C87944 ámbar cálido
const EMBER := Color(0.760, 0.286, 0.243)         # #C2493E ascua / óxido
const EMBER_DIM := Color(0.520, 0.196, 0.168)

const INK := Color(0.855, 0.831, 0.804)           # #DAD4CD texto principal cálido
const INK_DIM := Color(0.612, 0.565, 0.533)       # #9C9088 texto secundario
const INK_FAINT := Color(0.435, 0.400, 0.376)

# --- Superficies compuestas ------------------------------
const PANEL_BG := Color(0.086, 0.055, 0.047, 0.58)
const CARD_BG := Color(0.153, 0.106, 0.086, 0.42)
const BORDER := Color(0.470, 0.318, 0.286, 0.55)
const BORDER_HOT := Color(0.760, 0.286, 0.243, 0.85)
const SEPARATOR := Color(0.760, 0.286, 0.243, 0.24)

# Recortes reales (sin margen transparente) de los títulos
# gráficos del proyecto. Si se sustituye el arte, la firma
# cambia y se usa el lienzo completo como respaldo.
const TITLE_REGION_NEW_GAME := Rect2(32, 130, 2111, 485)
const TITLE_REGION_CONTINUE := Rect2(22, 206, 1953, 351)


# =========================================================
# CAJAS / SUPERFICIES
# =========================================================

static func flat_box(
	bg: Color,
	border: Color,
	border_width: int = 1,
	radius: int = 3,
	margin_h: float = 10.0,
	margin_v: float = 6.0
) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_width)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = margin_h
	sb.content_margin_right = margin_h
	sb.content_margin_top = margin_v
	sb.content_margin_bottom = margin_v
	return sb


static func panel_box(margin_h: float = 16.0, margin_v: float = 13.0) -> StyleBoxFlat:
	var sb := flat_box(PANEL_BG, BORDER, 1, 4, margin_h, margin_v)
	sb.shadow_color = Color(0, 0, 0, 0.45)
	sb.shadow_size = 8
	sb.shadow_offset = Vector2(0, 3)
	return sb


static func card_box(margin_h: float = 11.0, margin_v: float = 7.0) -> StyleBoxFlat:
	return flat_box(CARD_BG, BORDER, 1, 2, margin_h, margin_v)


# =========================================================
# TEXTO
# =========================================================

static func label(text: String, size: int = 13, color: Color = INK) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


static func caption(text: String, size: int = 11, color: Color = INK_DIM) -> Label:
	var l := label(text, size, color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.45))
	l.add_theme_constant_override("outline_size", 2)
	return l


static func accent_caption(text: String, size: int = 11) -> Label:
	return caption(text, size, CYAN_DIM)


static func label_over_scene(text: String, size: int = 12, color: Color = INK_DIM) -> Label:
	var l := label(text, size, color)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	l.add_theme_constant_override("shadow_offset_x", 1)
	l.add_theme_constant_override("shadow_offset_y", 1)
	l.add_theme_constant_override("shadow_outline_size", 2)
	return l


# =========================================================
# SEPARADORES E INDICADORES
# =========================================================

static func separator() -> ColorRect:
	var line := ColorRect.new()
	line.color = SEPARATOR
	line.custom_minimum_size = Vector2(0, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return line


static func signal_row(text: String = "SEÑAL 13.0 MHz", active: bool = true) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 6)

	var dot := ColorRect.new()
	dot.color = ALARM if active else Color(INK_FAINT.r, INK_FAINT.g, INK_FAINT.b, 0.55)
	dot.custom_minimum_size = Vector2(6, 6)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(dot)

	var text_label := label(text, 10, INK_FAINT)
	text_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(text_label)

	return row


# =========================================================
# TÍTULOS GRÁFICOS
# =========================================================

static func title_image(
	path: String,
	fallback_text: String,
	target_width: float = 300.0,
	max_height: float = 52.0
) -> Control:
	if not ResourceLoader.exists(path):
		return _title_fallback(fallback_text, max_height)

	var tex := load(path) as Texture2D
	if tex == null:
		return _title_fallback(fallback_text, max_height)

	var region := _title_region(path, tex)
	var aspect: float = region.size.x / max(region.size.y, 1.0)

	var width := target_width
	var height := width / aspect
	if height > max_height:
		height = max_height
		width = height * aspect

	var atlas := AtlasTexture.new()
	atlas.atlas = tex
	atlas.region = region

	var tr := TextureRect.new()
	tr.texture = atlas
	tr.custom_minimum_size = Vector2(width, height)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tr


static func _title_region(path: String, tex: Texture2D) -> Rect2:
	match path:
		"res://images/ui/title_new_game.png":
			return TITLE_REGION_NEW_GAME
		"res://images/ui/title_continue.png":
			return TITLE_REGION_CONTINUE
	return Rect2(Vector2.ZERO, tex.get_size())


static func _title_fallback(text: String, max_height: float) -> Label:
	var l := label(text, int(max_height * 0.5), INK)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return l


# =========================================================
# CONTROLES NATIVOS
# =========================================================

static func style_option(option: OptionButton) -> void:
	option.add_theme_stylebox_override("normal", flat_box(Color(0.086, 0.055, 0.047, 0.72), BORDER, 1, 2, 9.0, 5.0))
	option.add_theme_stylebox_override("hover", flat_box(Color(0.165, 0.098, 0.082, 0.85), BORDER_HOT, 1, 2, 9.0, 5.0))
	option.add_theme_stylebox_override("pressed", flat_box(Color(0.055, 0.030, 0.026, 0.92), EMBER_DIM, 1, 2, 9.0, 5.0))
	option.add_theme_stylebox_override("focus", flat_box(Color(0, 0, 0, 0), EMBER, 1, 2, 9.0, 5.0))
	option.add_theme_stylebox_override("disabled", flat_box(Color(0.06, 0.045, 0.04, 0.40), Color(0.30, 0.26, 0.24, 0.30), 1, 2, 9.0, 5.0))
	option.add_theme_color_override("font_color", INK)
	option.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	option.add_theme_color_override("font_focus_color", INK)
	option.add_theme_color_override("font_disabled_color", INK_FAINT)
	option.add_theme_font_size_override("font_size", 12)

	var pop := option.get_popup()
	pop.add_theme_stylebox_override("panel", flat_box(Color(0.043, 0.031, 0.028, 0.97), BORDER, 1, 2, 6.0, 5.0))
	pop.add_theme_stylebox_override("hover", flat_box(Color(0.165, 0.098, 0.082, 0.92), BORDER_HOT, 0, 1, 6.0, 4.0))
	pop.add_theme_color_override("font_color", INK_DIM)
	pop.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	pop.add_theme_font_size_override("font_size", 12)
	pop.add_theme_constant_override("v_separation", 5)


static func style_line_edit(edit: LineEdit) -> void:
	edit.add_theme_stylebox_override("normal", flat_box(Color(0.086, 0.055, 0.047, 0.72), BORDER, 1, 2, 9.0, 5.0))
	edit.add_theme_stylebox_override("focus", flat_box(Color(0.122, 0.070, 0.060, 0.88), BORDER_HOT, 1, 2, 9.0, 5.0))
	edit.add_theme_stylebox_override("read_only", flat_box(Color(0.043, 0.031, 0.028, 0.50), BORDER, 1, 2, 9.0, 5.0))
	edit.add_theme_color_override("font_color", INK)
	edit.add_theme_color_override("font_placeholder_color", INK_FAINT)
	edit.add_theme_color_override("caret_color", AMBER)
	edit.add_theme_color_override("selection_color", Color(0.760, 0.286, 0.243, 0.32))
	edit.add_theme_font_size_override("font_size", 12)

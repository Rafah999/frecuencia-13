class_name F13Style
extends RefCounted

# =========================================================
# FRECUENCIA 13 — Hoja de estilo de interfaz
# Horror psicológico / radio analógica.
# Colores planos y fábricas reutilizables para no duplicar UI.
# =========================================================

const INK := Color(0.87, 0.90, 0.92)
const INK_DIM := Color(0.66, 0.70, 0.73)
const INK_FAINT := Color(0.45, 0.49, 0.52)

const CYAN := Color(0.36, 0.76, 0.82)
const CYAN_DIM := Color(0.22, 0.44, 0.50)
const ALARM := Color(0.76, 0.14, 0.15)

const PANEL_BG := Color(0.015, 0.025, 0.035, 0.74)
const CARD_BG := Color(0.02, 0.03, 0.04, 0.66)
const BORDER := Color(0.42, 0.50, 0.55, 0.38)
const BORDER_HOT := Color(0.36, 0.76, 0.82, 0.85)


static func flat_box(
	bg: Color,
	border: Color,
	width: int = 1,
	radius: int = 3,
	margin: float = 12.0
) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(width)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = margin
	sb.content_margin_right = margin
	sb.content_margin_top = margin
	sb.content_margin_bottom = margin
	return sb


static func panel_box(margin: float = 20.0) -> StyleBoxFlat:
	var sb := flat_box(PANEL_BG, BORDER, 1, 4, margin)
	sb.shadow_color = Color(0, 0, 0, 0.55)
	sb.shadow_size = 10
	sb.shadow_offset = Vector2(0, 4)
	return sb


static func card_box() -> StyleBoxFlat:
	return flat_box(CARD_BG, BORDER, 1, 2, 12.0)


static func label(text: String, size: int = 14, color: Color = INK) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


static func caption(text: String, size: int = 11) -> Label:
	var l := label(text, size, CYAN)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	l.add_theme_constant_override("outline_size", 2)
	return l


static func separator() -> ColorRect:
	var line := ColorRect.new()
	line.color = Color(0.36, 0.76, 0.82, 0.28)
	line.custom_minimum_size = Vector2(0, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return line


static func signal_row(text: String = "SEÑAL 13.0 MHz") -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	var dot := ColorRect.new()
	dot.color = ALARM
	dot.custom_minimum_size = Vector2(6, 6)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(dot)

	var text_label := label(text, 10, INK_FAINT)
	text_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(text_label)

	return row


static func title_image(path: String, fallback_text: String, height: float = 64.0) -> Control:
	if ResourceLoader.exists(path):
		var tr := TextureRect.new()
		tr.texture = load(path) as Texture2D
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.custom_minimum_size = Vector2(0, height)
		tr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return tr

	var l := label(fallback_text, int(height * 0.42), INK)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l


static func style_option(option: OptionButton) -> void:
	option.add_theme_stylebox_override("normal", flat_box(Color(0.03, 0.04, 0.05, 0.70), BORDER, 1, 2, 10.0))
	option.add_theme_stylebox_override("hover", flat_box(Color(0.05, 0.08, 0.09, 0.85), BORDER_HOT, 1, 2, 10.0))
	option.add_theme_stylebox_override("pressed", flat_box(Color(0.02, 0.03, 0.04, 0.90), CYAN_DIM, 1, 2, 10.0))
	option.add_theme_stylebox_override("focus", flat_box(Color(0, 0, 0, 0), CYAN, 1, 2, 10.0))
	option.add_theme_stylebox_override("disabled", flat_box(Color(0.03, 0.03, 0.03, 0.40), Color(0.3, 0.3, 0.3, 0.3), 1, 2, 10.0))
	option.add_theme_color_override("font_color", INK)
	option.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	option.add_theme_color_override("font_focus_color", CYAN)
	option.add_theme_color_override("font_disabled_color", INK_FAINT)
	option.add_theme_font_size_override("font_size", 13)

	var pop := option.get_popup()
	pop.add_theme_stylebox_override("panel", flat_box(Color(0.02, 0.03, 0.04, 0.97), BORDER, 1, 2, 6.0))
	pop.add_theme_stylebox_override("hover", flat_box(Color(0.08, 0.12, 0.14, 0.92), BORDER_HOT, 0, 1, 6.0))
	pop.add_theme_color_override("font_color", INK_DIM)
	pop.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	pop.add_theme_font_size_override("font_size", 13)
	pop.add_theme_constant_override("v_separation", 6)


static func style_line_edit(edit: LineEdit) -> void:
	edit.add_theme_stylebox_override("normal", flat_box(Color(0.02, 0.03, 0.04, 0.70), BORDER, 1, 2, 8.0))
	edit.add_theme_stylebox_override("focus", flat_box(Color(0.03, 0.05, 0.06, 0.85), BORDER_HOT, 1, 2, 8.0))
	edit.add_theme_stylebox_override("read_only", flat_box(Color(0.02, 0.02, 0.02, 0.50), BORDER, 1, 2, 8.0))
	edit.add_theme_color_override("font_color", INK)
	edit.add_theme_color_override("font_placeholder_color", INK_FAINT)
	edit.add_theme_color_override("caret_color", CYAN)
	edit.add_theme_color_override("selection_color", Color(0.36, 0.76, 0.82, 0.35))
	edit.add_theme_font_size_override("font_size", 13)

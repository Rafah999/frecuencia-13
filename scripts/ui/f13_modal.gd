class_name F13Modal
extends Control

# Modal reutilizable con la estética de Frecuencia 13.
# Sustituye a ConfirmationDialog para poder animarlo y estilizarlo igual
# en la vista de detalles y en la confirmación de borrado.
# El botón principal (cargar / confirmar) usa el tono PRIMARY; el de
# borrado usa DANGER.

signal confirmed
signal cancelled

var _title: Label
var _body: Label
var _ok: F13Button
var _cancel: F13Button
var _panel: PanelContainer


func _init() -> void:
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var backdrop := ColorRect.new()
	backdrop.color = Color(0, 0, 0, 0.60)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(400, 0)
	_panel.add_theme_stylebox_override("panel", F13Style.panel_box(16.0, 13.0))
	center.add_child(_panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	_panel.add_child(content)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 7)
	content.add_child(header)

	var marker := ColorRect.new()
	marker.color = F13Style.EMBER
	marker.custom_minimum_size = Vector2(3, 13)
	marker.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(marker)

	_title = F13Style.caption("", 12, F13Style.INK)
	header.add_child(_title)

	content.add_child(F13Style.separator())

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 150)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(scroll)

	_body = F13Style.label("", 12, F13Style.INK_DIM)
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.custom_minimum_size = Vector2(356, 0)
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_body)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_END
	row.add_theme_constant_override("separation", 10)
	content.add_child(row)

	_cancel = F13Button.new()
	_cancel.text = "CANCELAR"
	_cancel.custom_minimum_size = Vector2(120, 30)
	_cancel.pressed.connect(_on_cancel)
	row.add_child(_cancel)

	_ok = F13Button.new()
	_ok.tone = F13Button.Tone.PRIMARY
	_ok.text = "ACEPTAR"
	_ok.custom_minimum_size = Vector2(140, 30)
	_ok.pressed.connect(_on_ok)
	row.add_child(_ok)

	_panel.resized.connect(_sync_pivot)


func _sync_pivot() -> void:
	_panel.pivot_offset = _panel.size * 0.5


func open(
	title: String,
	body: String,
	ok_text: String = "ACEPTAR",
	cancel_text: String = "CANCELAR",
	show_cancel: bool = true,
	ok_tone: F13Button.Tone = F13Button.Tone.PRIMARY
) -> void:
	_title.text = title
	_body.text = body
	_ok.text = ok_text
	_ok.tone = ok_tone
	_cancel.text = cancel_text
	_cancel.visible = show_cancel

	visible = true
	modulate.a = 0.0
	_sync_pivot()
	_panel.scale = Vector2(0.96, 0.96)

	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(self, "modulate:a", 1.0, 0.18)
	t.tween_property(_panel, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	_ok.grab_focus()


func close() -> void:
	if not visible:
		return
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.14)
	await t.finished
	visible = false


func _on_ok() -> void:
	confirmed.emit()
	close()


func _on_cancel() -> void:
	cancelled.emit()
	close()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_cancel()
		get_viewport().set_input_as_handled()

extends Control

const MAIN_MENU_SCENE := "res://scenes/menu/MainMenu.tscn"
const GAME_SCENE := "res://scenes/main/TestRoom.tscn"
const BACKGROUND_TEXTURE := "res://images/backgrounds/menu_continue.jpeg"
const TITLE_TEXTURE := "res://images/ui/title_continue.png"

var saves_container: VBoxContainer
var status_label: Label
var scroll: ScrollContainer
var empty_state: Control
var details_dialog: F13Modal
var delete_dialog: F13Modal

var selected_save_id := ""
var selected_save: Dictionary = {}

var _fade: ScreenFade
var _root: VBoxContainer


func _ready() -> void:
	_build_interface()
	_refresh_saves()
	await get_tree().process_frame
	_animate_in()


func _build_interface() -> void:
	_add_background()
	add_child(F13Overlay.new())

	_root = VBoxContainer.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.offset_left = 18
	_root.offset_top = 12
	_root.offset_right = -18
	_root.offset_bottom = -12
	_root.add_theme_constant_override("separation", 8)
	_root.modulate.a = 0.0
	add_child(_root)

	_root.add_child(F13Style.title_image(TITLE_TEXTURE, "CONTINUAR PARTIDA", 300.0, 50.0))

	var subtitle := F13Style.label_over_scene("Selecciona una partida guardada", 11, F13Style.INK_FAINT)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_root.add_child(subtitle)

	_root.add_child(F13Style.separator())

	status_label = F13Style.caption("", 11)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.custom_minimum_size = Vector2(0, 15)
	_root.add_child(status_label)

	scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	_root.add_child(scroll)

	saves_container = VBoxContainer.new()
	saves_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	saves_container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	saves_container.add_theme_constant_override("separation", 6)
	scroll.add_child(saves_container)

	empty_state = _build_empty_state()
	empty_state.visible = false
	_root.add_child(empty_state)

	var bottom := HBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom.add_theme_constant_override("separation", 12)
	_root.add_child(bottom)

	var refresh_button := F13Button.new()
	refresh_button.text = "ACTUALIZAR"
	refresh_button.custom_minimum_size = Vector2(140, 30)
	refresh_button.pressed.connect(_refresh_saves)
	bottom.add_child(refresh_button)

	var back_button := F13Button.new()
	back_button.text = "VOLVER"
	back_button.custom_minimum_size = Vector2(140, 30)
	back_button.pressed.connect(_back_to_menu)
	bottom.add_child(back_button)

	details_dialog = F13Modal.new()
	details_dialog.confirmed.connect(_load_selected_save)
	add_child(details_dialog)

	delete_dialog = F13Modal.new()
	delete_dialog.confirmed.connect(_delete_selected_save)
	add_child(delete_dialog)

	_fade = ScreenFade.new()
	add_child(_fade)

	# Interferencia que afecta a TODA la pantalla (por encima de la UI).
	add_child(F13Overlay.new(F13Overlay.Layer.INTERFERENCE))


func _build_empty_state() -> Control:
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 7)
	center.add_child(column)

	column.add_child(F13Style.signal_row("SEÑAL PERDIDA", false))

	var message := F13Style.caption("NO HAY REGISTROS DISPONIBLES", 12, F13Style.INK_DIM)
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(message)

	var hint := F13Style.label_over_scene("Crea una partida nueva o pulsa ACTUALIZAR", 10, F13Style.INK_FAINT)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(hint)

	return center


func _add_background() -> void:
	var background := TextureRect.new()
	background.name = "Background"
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if ResourceLoader.exists(BACKGROUND_TEXTURE):
		background.texture = load(BACKGROUND_TEXTURE) as Texture2D
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	move_child(background, 0)


func _animate_in() -> void:
	_root.pivot_offset = _root.size * 0.5
	var t := create_tween()
	t.tween_property(_root, "modulate:a", 1.0, 0.28)


func _refresh_saves() -> void:
	for child in saves_container.get_children():
		saves_container.remove_child(child)
		child.queue_free()

	var saves: Array[Dictionary] = SaveManager.get_saves()

	if saves.is_empty():
		scroll.visible = false
		empty_state.visible = true
		status_label.text = ""
		return

	empty_state.visible = false
	scroll.visible = true
	status_label.text = "REGISTROS DISPONIBLES: " + str(saves.size())

	for save_data in saves:
		_add_save_card(save_data)


func _add_save_card(data: Dictionary) -> void:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	panel.add_theme_stylebox_override("panel", F13Style.card_box())
	saves_container.add_child(panel)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)

	var accent := ColorRect.new()
	accent.color = F13Style.CYAN_DIM
	accent.custom_minimum_size = Vector2(2, 0)
	accent.size_flags_vertical = Control.SIZE_FILL
	accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(accent)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	info.add_theme_constant_override("separation", 1)
	row.add_child(info)

	var name_label := F13Style.label(_ellipsize(str(data.get("name", "Partida sin nombre"))), 13, F13Style.INK)
	info.add_child(name_label)

	var chapter_label := F13Style.label(
		_chapter_name(int(data.get("chapter", 1))), 10, F13Style.INK_FAINT
	)
	info.add_child(chapter_label)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 8)
	buttons.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(buttons)

	var details_button := F13Button.new()
	details_button.text = "DETALLES"
	details_button.custom_minimum_size = Vector2(98, 28)
	details_button.pressed.connect(_show_details.bind(data.duplicate(true)))
	buttons.add_child(details_button)

	var delete_button := F13Button.new()
	delete_button.tone = F13Button.Tone.DANGER
	delete_button.text = "ELIMINAR"
	delete_button.custom_minimum_size = Vector2(98, 28)
	delete_button.pressed.connect(
		_ask_delete.bind(
			str(data.get("id", "")),
			str(data.get("name", "esta partida"))
		)
	)
	buttons.add_child(delete_button)


func _ellipsize(text: String, max_length: int = 32) -> String:
	if text.length() <= max_length:
		return text
	return text.substr(0, max_length - 1) + "…"


func _show_details(data: Dictionary) -> void:
	selected_save = data
	selected_save_id = str(data.get("id", ""))

	var play_time := int(data.get("play_time_seconds", 0))
	var position_data: Dictionary = data.get("player_position", {})
	var scene_path := str(data.get("scene_path", GAME_SCENE))
	var completed := int(
		data.get("progress", {}).get("objectives_completed", 0)
	)
	var total := int(
		data.get("progress", {}).get("objectives_total", 0)
	)

	var position_text := "No registrada"
	if not position_data.is_empty():
		position_text = "X: %.1f, Y: %.1f" % [
			float(position_data.get("x", 320.0)),
			float(position_data.get("y", 180.0))
		]

	var text := (
		"Nombre: " + str(data.get("name", "Sin nombre")) + "\n\n"
		+ "Capítulo: " + _chapter_name(int(data.get("chapter", 1))) + "\n"
		+ "Dificultad: " + str(data.get("difficulty", "Normal")) + "\n"
		+ "Tiempo jugado: " + SaveManager.format_play_time(play_time) + "\n"
		+ "Último guardado: " + str(data.get("updated_at", "Desconocido")) + "\n"
		+ "Objetivos: " + str(completed) + " / " + str(total) + "\n"
		+ "Escena: " + scene_path + "\n"
		+ "Posición: " + position_text + "\n"
		+ "Tamaño: " + SaveManager.format_size(
			int(data.get("size_bytes", 0))
		)
	)

	details_dialog.open(
		"DETALLES DE LA PARTIDA", text, "CARGAR PARTIDA", "VOLVER", true,
		F13Button.Tone.PRIMARY
	)


func _ask_delete(save_id: String, save_name: String) -> void:
	selected_save_id = save_id
	var text := (
		"¿Seguro que deseas eliminar «" + save_name + "»?\n"
		+ "Esta acción no se puede deshacer."
	)
	delete_dialog.open(
		"ELIMINAR PARTIDA", text, "ELIMINAR", "CANCELAR", true,
		F13Button.Tone.DANGER
	)


func _delete_selected_save() -> void:
	if selected_save_id.is_empty():
		return

	var deleted := SaveManager.delete_save(selected_save_id)
	selected_save_id = ""

	_refresh_saves()
	status_label.text = "Partida eliminada." if deleted else "No se pudo eliminar la partida."


func _load_selected_save() -> void:
	var data := SaveManager.load_save(selected_save_id)

	if data.is_empty():
		status_label.text = "No se pudo cargar la partida."
		_refresh_saves()
		return

	GameSession.current_save_id = selected_save_id
	GameSession.current_chapter = int(data.get("chapter", 1))
	GameSession.current_difficulty = str(
		data.get("difficulty", "Normal")
	)

	var error: int = await _fade.change_scene(
		str(data.get("scene_path", GAME_SCENE))
	)

	if error != OK:
		status_label.text = "No se pudo abrir la escena de juego."


func _chapter_name(chapter: int) -> String:
	match chapter:
		1:
			return "Capítulo 1 — La estación"
		2:
			return "Capítulo 2 — Las interferencias"
		3:
			return "Capítulo 3 — El laboratorio"
		_:
			return "Capítulo " + str(chapter)


func _back_to_menu() -> void:
	await _fade.change_scene(MAIN_MENU_SCENE)

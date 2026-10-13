extends Control

const MAIN_MENU_SCENE := "res://scenes/menu/MainMenu.tscn"
const GAME_SCENE := "res://scenes/main/TestRoom.tscn"
const BACKGROUND_TEXTURE := "res://images/backgrounds/menu_continue.jpeg"
const TITLE_TEXTURE := "res://images/ui/title_continue.png"

var saves_container: VBoxContainer
var status_label: Label
var details_dialog: F13Modal
var delete_dialog: F13Modal

var selected_save_id := ""
var selected_save: Dictionary = {}

var _fade: ScreenFade


func _ready() -> void:
	_build_interface()
	_refresh_saves()


func _build_interface() -> void:
	_add_background()
	_add_vignette()

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 20
	root.offset_top = 14
	root.offset_right = -20
	root.offset_bottom = -14
	root.add_theme_constant_override("separation", 8)
	add_child(root)

	root.add_child(F13Style.title_image(TITLE_TEXTURE, "CONTINUAR PARTIDA", 52.0))

	var subtitle := F13Style.label("Selecciona una partida guardada", 12, F13Style.INK_DIM)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(subtitle)

	root.add_child(F13Style.separator())

	status_label = F13Style.caption("", 11)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(status_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	root.add_child(scroll)

	saves_container = VBoxContainer.new()
	saves_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	saves_container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	saves_container.add_theme_constant_override("separation", 8)
	scroll.add_child(saves_container)

	var bottom := HBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom.add_theme_constant_override("separation", 12)
	root.add_child(bottom)

	var refresh_button := F13Button.new()
	refresh_button.text = "ACTUALIZAR"
	refresh_button.custom_minimum_size = Vector2(150, 32)
	refresh_button.pressed.connect(_refresh_saves)
	bottom.add_child(refresh_button)

	var back_button := F13Button.new()
	back_button.text = "VOLVER"
	back_button.custom_minimum_size = Vector2(150, 32)
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


func _add_background() -> void:
	var background := TextureRect.new()
	background.name = "Background"
	if ResourceLoader.exists(BACKGROUND_TEXTURE):
		background.texture = load(BACKGROUND_TEXTURE) as Texture2D
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	move_child(background, 0)


func _add_vignette() -> void:
	var vignette := ColorRect.new()
	vignette.color = Color(0, 0, 0, 0.34)
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette)


func _refresh_saves() -> void:
	for child in saves_container.get_children():
		saves_container.remove_child(child)
		child.queue_free()

	var saves: Array[Dictionary] = SaveManager.get_saves()

	if saves.is_empty():
		status_label.text = "No hay partidas guardadas."
		return

	status_label.text = "Partidas encontradas: " + str(saves.size())

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

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	row.add_child(info)

	var name_label := F13Style.label(str(data.get("name", "Partida sin nombre")), 15)
	info.add_child(name_label)

	var chapter_label := F13Style.label(
		_chapter_name(int(data.get("chapter", 1))), 11, F13Style.INK_FAINT
	)
	info.add_child(chapter_label)

	var details_button := F13Button.new()
	details_button.text = "DETALLES"
	details_button.custom_minimum_size = Vector2(110, 30)
	details_button.pressed.connect(_show_details.bind(data.duplicate(true)))
	row.add_child(details_button)

	var delete_button := F13Button.new()
	delete_button.text = "ELIMINAR"
	delete_button.custom_minimum_size = Vector2(110, 30)
	delete_button.pressed.connect(
		_ask_delete.bind(
			str(data.get("id", "")),
			str(data.get("name", "esta partida"))
		)
	)
	row.add_child(delete_button)


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

	details_dialog.open("DETALLES DE LA PARTIDA", text, "CARGAR PARTIDA", "VOLVER")


func _ask_delete(save_id: String, save_name: String) -> void:
	selected_save_id = save_id
	var text := (
		"¿Seguro que deseas eliminar «" + save_name + "»?\n"
		+ "Esta acción no se puede deshacer."
	)
	delete_dialog.open("ELIMINAR PARTIDA", text, "ELIMINAR", "CANCELAR")


func _delete_selected_save() -> void:
	if selected_save_id.is_empty():
		return

	var deleted := SaveManager.delete_save(selected_save_id)
	selected_save_id = ""

	if deleted:
		status_label.text = "Partida eliminada."
	else:
		status_label.text = "No se pudo eliminar la partida."

	_refresh_saves()


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
		status_label.text = "No se pudo abrir la escena guardada."


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

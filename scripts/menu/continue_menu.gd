
extends Control

const MAIN_MENU_SCENE := "res://scenes/menu/MainMenu.tscn"
const GAME_SCENE := "res://scenes/main/TestRoom.tscn"

var saves_container: VBoxContainer
var status_label: Label
var details_dialog: ConfirmationDialog
var delete_dialog: ConfirmationDialog

var selected_save_id := ""
var selected_save: Dictionary = {}


func _ready() -> void:
	_build_interface()
	_refresh_saves()


func _build_interface() -> void:

	# Fondo
	
	# Fondo
	var background := TextureRect.new()
	background.name = "Background"
	background.texture = load(
		"res://images/backgrounds/menu_continue.jpeg"
	) as Texture2D

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(background)
	move_child(background, 0)
	
	print("Textura: ", background.texture)
	print("Tamaño del fondo: ", background.size)



	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 24
	root.offset_top = 18
	root.offset_right = -24
	root.offset_bottom = -18
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var title := Label.new()
	title.text = "CONTINUAR PARTIDA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 25)
	root.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Selecciona una partida guardada"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(subtitle)

	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(status_label)

	saves_container = VBoxContainer.new()
	saves_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	saves_container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	saves_container.add_theme_constant_override("separation", 10)
	root.add_child(saves_container)

	var bottom := HBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom.add_theme_constant_override("separation", 12)
	root.add_child(bottom)

	var refresh_button := Button.new()
	refresh_button.text = "ACTUALIZAR"
	refresh_button.pressed.connect(_refresh_saves)
	bottom.add_child(refresh_button)

	var back_button := Button.new()
	back_button.text = "VOLVER"
	back_button.pressed.connect(_back_to_menu)
	bottom.add_child(back_button)

	details_dialog = ConfirmationDialog.new()
	details_dialog.title = "DETALLES DE LA PARTIDA"
	details_dialog.ok_button_text = "CARGAR PARTIDA"
	details_dialog.cancel_button_text = "VOLVER"
	details_dialog.confirmed.connect(_load_selected_save)
	add_child(details_dialog)

	delete_dialog = ConfirmationDialog.new()
	delete_dialog.title = "ELIMINAR PARTIDA"
	delete_dialog.dialog_text = "¿Seguro que deseas eliminar esta partida?"
	delete_dialog.ok_button_text = "ELIMINAR"
	delete_dialog.cancel_button_text = "CANCELAR"
	delete_dialog.confirmed.connect(_delete_selected_save)
	add_child(delete_dialog)


func _refresh_saves() -> void:
	for child in saves_container.get_children():
		saves_container.remove_child(child)
		child.queue_free()

	var saves: Array[Dictionary] = SaveManager.get_saves()

	print("PARTIDAS ENCONTRADAS: ", saves.size())

	if saves.is_empty():
		status_label.text = "No hay partidas guardadas."
		return

	status_label.text = "Partidas encontradas: " + str(saves.size())

	for save_data in saves:
		print("CREANDO TARJETA: ", save_data.get("name", "Sin nombre"))
		_add_save_card(save_data)

	print("TARJETAS EN EL CONTENEDOR: ", saves_container.get_child_count())


func _add_save_card(data: Dictionary) -> void:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	saves_container.add_child(panel)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)

	var name_label := Label.new()
	name_label.text = str(data.get("name", "Partida sin nombre"))
	name_label.add_theme_font_size_override("font_size", 16)
	info.add_child(name_label)

	var chapter_label := Label.new()
	chapter_label.text = _chapter_name(int(data.get("chapter", 1)))
	chapter_label.add_theme_font_size_override("font_size", 12)
	info.add_child(chapter_label)

	var details_button := Button.new()
	details_button.text = "DETALLES"
	details_button.pressed.connect(
		_show_details.bind(data.duplicate(true))
	)
	row.add_child(details_button)

	var delete_button := Button.new()
	delete_button.text = "ELIMINAR"
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

	details_dialog.dialog_text = text
	details_dialog.popup_centered()


func _ask_delete(save_id: String, save_name: String) -> void:
	selected_save_id = save_id
	delete_dialog.dialog_text = (
		"¿Seguro que deseas eliminar «" + save_name + "»?\n"
		+ "Esta acción no se puede deshacer."
	)
	delete_dialog.popup_centered()


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
		details_dialog.hide()
		status_label.text = "No se pudo cargar la partida."
		_refresh_saves()
		return

	GameSession.current_save_id = selected_save_id
	GameSession.current_chapter = int(data.get("chapter", 1))
	GameSession.current_difficulty = str(
		data.get("difficulty", "Normal")
	)

	var error := get_tree().change_scene_to_file(
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
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

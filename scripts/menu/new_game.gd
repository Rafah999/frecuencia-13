
extends Control

const GAME_SCENE := "res://scenes/main/TestRoom.tscn"

var selected_chapter: int = 1
var selected_difficulty: String = "Normal"

var chapter_option: OptionButton
var difficulty_option: OptionButton
var save_name_input: LineEdit
var message_label: Label


func _ready() -> void:
	_build_interface()


func _build_interface() -> void:

	# Fondo
	var background := TextureRect.new()
	background.name = "Background"
	background.texture = load(
		"res://images/backgrounds/menu_new_game.jpeg"
	) as Texture2D

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Añadir el fondo antes de los controles.
	add_child(background)
	move_child(background, 0)
	print("Textura: ", background.texture)
	print("Tamaño del fondo: ", background.size)



	# Desplazamiento: permite subir/bajar si el contenido supera la pantalla
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	add_child(scroll)

	# Contenedor central (dentro del scroll, para seguir centrando cuando cabe)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	var panel := VBoxContainer.new()
	panel.custom_minimum_size = Vector2(360, 0)
	panel.add_theme_constant_override("separation", 14)
	center.add_child(panel)

	# Título
	var title := Label.new()
	title.text = "NUEVO JUEGO"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	panel.add_child(title)

	# Capítulo
	panel.add_child(_make_label("CAPÍTULO"))

	chapter_option = OptionButton.new()
	chapter_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var unlocked: Array = SaveManager.get_unlocked_chapters()

	for chapter in unlocked:
		chapter_option.add_item(_chapter_name(int(chapter)), int(chapter))

	panel.add_child(chapter_option)

	# Dificultad
	panel.add_child(_make_label("DIFICULTAD"))

	difficulty_option = OptionButton.new()
	difficulty_option.add_item("Fácil")
	difficulty_option.add_item("Normal")
	difficulty_option.add_item("Difícil")
	difficulty_option.select(1)
	panel.add_child(difficulty_option)

	# Nombre
	panel.add_child(_make_label("NOMBRE DE LA PARTIDA"))

	save_name_input = LineEdit.new()
	save_name_input.placeholder_text = "Ej.: Mi primera noche"
	save_name_input.max_length = 40
	panel.add_child(save_name_input)

	# Mensajes
	message_label = Label.new()
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(message_label)

	# Botones
	var start_button := Button.new()
	start_button.text = "COMENZAR"
	start_button.custom_minimum_size.y = 38
	start_button.pressed.connect(_on_start_pressed)
	panel.add_child(start_button)

	var back_button := Button.new()
	back_button.text = "VOLVER AL MENÚ"
	back_button.custom_minimum_size.y = 38
	back_button.pressed.connect(_on_back_pressed)
	panel.add_child(back_button)


func _make_label(text_value: String) -> Label:
	var label := Label.new()
	label.text = text_value
	return label


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


func _on_start_pressed() -> void:
	var save_name := save_name_input.text.strip_edges()

	if save_name.is_empty():
		message_label.text = "Escribe un nombre para la partida."
		return

	selected_chapter = chapter_option.get_selected_id()

	match difficulty_option.selected:
		0:
			selected_difficulty = "Fácil"
		1:
			selected_difficulty = "Normal"
		2:
			selected_difficulty = "Difícil"

	var save_data := SaveManager.create_save(
		save_name,
		selected_chapter,
		selected_difficulty
	)

	if save_data.is_empty():
		message_label.text = "No se pudo crear la partida."
		return

	GameSession.current_save_id = str(save_data["id"])
	GameSession.current_chapter = selected_chapter
	GameSession.current_difficulty = selected_difficulty

	var error := get_tree().change_scene_to_file(GAME_SCENE)

	if error != OK:
		message_label.text = "No se pudo abrir la escena de juego."


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/MainMenu.tscn")

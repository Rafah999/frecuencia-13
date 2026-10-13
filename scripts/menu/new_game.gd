extends Control

const GAME_SCENE := "res://scenes/main/TestRoom.tscn"
const MAIN_MENU_SCENE := "res://scenes/menu/MainMenu.tscn"
const BACKGROUND_TEXTURE := "res://images/backgrounds/menu_new_game.jpeg"
const TITLE_TEXTURE := "res://images/ui/title_new_game.png"

var selected_chapter: int = 1
var selected_difficulty: String = "Normal"

var chapter_option: OptionButton
var difficulty_option: OptionButton
var save_name_input: LineEdit
var message_label: Label

var _fade: ScreenFade
var _panel: PanelContainer


func _ready() -> void:
	_build_interface()
	_animate_in()


func _build_interface() -> void:
	_add_background()
	_add_vignette()

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	add_child(scroll)

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(420, 0)
	_panel.add_theme_stylebox_override("panel", F13Style.panel_box(20.0))
	center.add_child(_panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	_panel.add_child(content)

	content.add_child(F13Style.title_image(TITLE_TEXTURE, "NUEVO JUEGO", 58.0))
	content.add_child(F13Style.signal_row())
	content.add_child(F13Style.separator())

	# Capítulo
	content.add_child(F13Style.caption("CAPÍTULO"))
	chapter_option = OptionButton.new()
	chapter_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	F13Style.style_option(chapter_option)
	var unlocked: Array = SaveManager.get_unlocked_chapters()
	for chapter in unlocked:
		chapter_option.add_item(_chapter_name(int(chapter)), int(chapter))
	content.add_child(chapter_option)

	# Dificultad
	content.add_child(F13Style.caption("DIFICULTAD"))
	difficulty_option = OptionButton.new()
	difficulty_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	F13Style.style_option(difficulty_option)
	difficulty_option.add_item("Fácil")
	difficulty_option.add_item("Normal")
	difficulty_option.add_item("Difícil")
	difficulty_option.select(1)
	content.add_child(difficulty_option)

	# Nombre
	content.add_child(F13Style.caption("NOMBRE DE LA PARTIDA"))
	save_name_input = LineEdit.new()
	save_name_input.placeholder_text = "Ej.: Mi primera noche"
	save_name_input.max_length = 40
	F13Style.style_line_edit(save_name_input)
	content.add_child(save_name_input)

	# Mensajes
	message_label = F13Style.label("", 12, F13Style.ALARM)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(message_label)

	# Botones
	var start_button := F13Button.new()
	start_button.text = "COMENZAR"
	start_button.pressed.connect(_on_start_pressed)
	content.add_child(start_button)

	var back_button := F13Button.new()
	back_button.text = "VOLVER AL MENÚ"
	back_button.pressed.connect(_on_back_pressed)
	content.add_child(back_button)

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
	vignette.color = Color(0, 0, 0, 0.30)
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette)


func _animate_in() -> void:
	_panel.pivot_offset = _panel.size * 0.5
	_panel.modulate.a = 0.0
	_panel.scale = Vector2(0.98, 0.98)
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(_panel, "modulate:a", 1.0, 0.25)
	t.tween_property(_panel, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


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

	message_label.text = ""
	var error: int = await _fade.change_scene(GAME_SCENE)

	if error != OK:
		message_label.text = "No se pudo abrir la escena de juego."


func _on_back_pressed() -> void:
	await _fade.change_scene(MAIN_MENU_SCENE)

extends Control


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


# =========================================================
# CERRAR JUEGO
# =========================================================

func _on_exit_button_pressed() -> void:
	get_tree().quit()


# =========================================================
# NUEVO JUEGO
# =========================================================

func _on_new_game_button_mouse_entered() -> void:
	_hover_button($CenterContainer/VBoxContainer/MenuButtons/NewGameButton)


func _on_new_game_button_mouse_exited() -> void:
	_unhover_button($CenterContainer/VBoxContainer/MenuButtons/NewGameButton)


# =========================================================
# CONTINUAR
# =========================================================

func _on_continue_button_mouse_entered() -> void:
	_hover_button($CenterContainer/VBoxContainer/MenuButtons/ContinueButton)


func _on_continue_button_mouse_exited() -> void:
	_unhover_button($CenterContainer/VBoxContainer/MenuButtons/ContinueButton)


# =========================================================
# CONFIGURACIÓN
# =========================================================

func _on_options_button_mouse_entered() -> void:
	_hover_button($CenterContainer/VBoxContainer/MenuButtons/OptionsButton)


func _on_options_button_mouse_exited() -> void:
	_unhover_button($CenterContainer/VBoxContainer/MenuButtons/OptionsButton)


# =========================================================
# SALIR
# =========================================================

func _on_exit_button_mouse_entered() -> void:
	_hover_button($CenterContainer/VBoxContainer/MenuButtons/ExitButton)


func _on_exit_button_mouse_exited() -> void:
	_unhover_button($CenterContainer/VBoxContainer/MenuButtons/ExitButton)


# =========================================================
# EFECTO AL PASAR EL MOUSE
# =========================================================

func _hover_button(button: Button) -> void:

	# -----------------------------------------------------
	# MOSTRAR INTERFERENCIA
	# -----------------------------------------------------

	if button.has_node("StaticOverlay"):
		var static_overlay = button.get_node("StaticOverlay")

		static_overlay.visible = true
		static_overlay.position.x = 0.0
		static_overlay.modulate.a = 0.0

		var static_tween = create_tween()

		static_tween.tween_property(
			static_overlay,
			"modulate:a",
			0.75,
			0.05
		)

		static_tween.tween_property(
			static_overlay,
			"position:x",
			-3.0,
			0.025
		)

		static_tween.tween_property(
			static_overlay,
			"position:x",
			3.0,
			0.025
		)

		static_tween.tween_property(
			static_overlay,
			"position:x",
			-2.0,
			0.025
		)

		static_tween.tween_property(
			static_overlay,
			"position:x",
			2.0,
			0.025
		)

		static_tween.tween_property(
			static_overlay,
			"position:x",
			0.0,
			0.025
		)

	# -----------------------------------------------------
	# GUARDAR TEXTO ORIGINAL
	# -----------------------------------------------------

	if not button.has_meta("original_text"):
		button.set_meta("original_text", button.text)

	# -----------------------------------------------------
	# INDICADOR DE SELECCIÓN
	# -----------------------------------------------------

	button.text = "▶ " + button.get_meta("original_text")

	# -----------------------------------------------------
	# ANIMACIÓN DEL BOTÓN
	# -----------------------------------------------------

	var tween = create_tween()
	tween.set_parallel(true)

	# Aumentar ligeramente
	tween.tween_property(
		button,
		"scale",
		Vector2(1.05, 1.05),
		0.12
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Aumentar brillo
	tween.tween_property(
		button,
		"modulate",
		Color(1.15, 1.15, 1.15, 1.0),
		0.08
	)

	# Glitch
	_interference(button)


# =========================================================
# AL SACAR EL MOUSE
# =========================================================

func _unhover_button(button: Button) -> void:

	# -----------------------------------------------------
	# OCULTAR INTERFERENCIA
	# -----------------------------------------------------

	if button.has_node("StaticOverlay"):
		var static_overlay = button.get_node("StaticOverlay")

		static_overlay.visible = false
		static_overlay.position.x = 0.0
		static_overlay.modulate.a = 1.0

	# -----------------------------------------------------
	# RECUPERAR TEXTO ORIGINAL
	# -----------------------------------------------------

	if button.has_meta("original_text"):
		button.text = button.get_meta("original_text")

	# -----------------------------------------------------
	# VOLVER A ESTADO NORMAL
	# -----------------------------------------------------

	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		button,
		"scale",
		Vector2(1.0, 1.0),
		0.12
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		button,
		"modulate",
		Color(1.0, 1.0, 1.0, 1.0),
		0.08
	)

	tween.tween_property(
		button,
		"rotation",
		0.0,
		0.08
	)


# =========================================================
# INTERFERENCIA DE RADIO
# =========================================================

func _interference(button: Button) -> void:

	var glitch = create_tween()

	glitch.tween_property(
		button,
		"rotation",
		deg_to_rad(-1.0),
		0.03
	)

	glitch.tween_property(
		button,
		"rotation",
		deg_to_rad(1.0),
		0.03
	)

	glitch.tween_property(
		button,
		"rotation",
		deg_to_rad(-0.5),
		0.03
	)

	glitch.tween_property(
		button,
		"rotation",
		0.0,
		0.03
	)


extends Node2D

const ROOM_SIZE := Vector2(640.0, 360.0)
const WALL_THICKNESS := 20.0
const AUTOSAVE_INTERVAL := 60.0

var play_time_seconds: float = 0.0
var autosave_timer: Timer
var player: CharacterBody2D


func _ready() -> void:
	crear_paredes()
	crear_boton_salir()

	player = get_node_or_null("Player") as CharacterBody2D

	if player == null:
		push_error("No se encontró el nodo Player en TestRoom.")
		return

	_cargar_estado_partida()
	_iniciar_autoguardado()


func _process(delta: float) -> void:
	if player == null:
		return

	# El tiempo solo se acumula mientras esta escena está activa.
	play_time_seconds += delta


# =========================================================
# CARGAR EL ESTADO GUARDADO
# =========================================================

func _cargar_estado_partida() -> void:
	var save_id := GameSession.current_save_id

	if save_id.is_empty():
		return

	var data := SaveManager.load_save(save_id)

	if data.is_empty():
		return

	play_time_seconds = float(
		data.get("play_time_seconds", 0)
	)

	var scene_path := str(
		data.get("scene_path", "res://scenes/main/TestRoom.tscn")
	)

	# Restaurar la posición únicamente si el guardado corresponde
	# a esta escena.
	if scene_path == scene_file_path:
		var position_data: Dictionary = data.get(
			"player_position",
			{"x": 320.0, "y": 180.0}
		)

		player.global_position = Vector2(
			float(position_data.get("x", 320.0)),
			float(position_data.get("y", 180.0))
		)


# =========================================================
# AUTOGUARDADO
# =========================================================

func _iniciar_autoguardado() -> void:
	autosave_timer = Timer.new()
	autosave_timer.wait_time = AUTOSAVE_INTERVAL
	autosave_timer.one_shot = false
	autosave_timer.autostart = true

	add_child(autosave_timer)
	autosave_timer.timeout.connect(_guardar_automaticamente)


func _guardar_automaticamente() -> void:
	var save_id := GameSession.current_save_id

	if save_id.is_empty() or player == null:
		return

	var guardado := SaveManager.save_player_state(
		save_id,
		scene_file_path,
		player.global_position,
		GameSession.current_chapter,
		int(play_time_seconds),
		"automatico"
	)

	if guardado:
		print(
			"Autoguardado completado. Tiempo: ",
			SaveManager.format_play_time(int(play_time_seconds)),
			" | Posición: ",
			player.global_position
		)


# =========================================================
# GUARDAR ANTES DE SALIR
# =========================================================

func _guardar_antes_de_salir() -> void:
	var save_id := GameSession.current_save_id

	if save_id.is_empty() or player == null:
		return

	var guardado := SaveManager.save_player_state(
		save_id,
		scene_file_path,
		player.global_position,
		GameSession.current_chapter,
		int(play_time_seconds),
		"manual"
	)

	if not guardado:
		push_error("No se pudo guardar la partida antes de salir.")


# =========================================================
# PAREDES
# =========================================================

func crear_paredes() -> void:
	crear_pared(
		Vector2(ROOM_SIZE.x / 2.0, WALL_THICKNESS / 2.0),
		Vector2(ROOM_SIZE.x, WALL_THICKNESS)
	)

	crear_pared(
		Vector2(ROOM_SIZE.x / 2.0, ROOM_SIZE.y - WALL_THICKNESS / 2.0),
		Vector2(ROOM_SIZE.x, WALL_THICKNESS)
	)

	crear_pared(
		Vector2(WALL_THICKNESS / 2.0, ROOM_SIZE.y / 2.0),
		Vector2(WALL_THICKNESS, ROOM_SIZE.y)
	)

	crear_pared(
		Vector2(ROOM_SIZE.x - WALL_THICKNESS / 2.0, ROOM_SIZE.y / 2.0),
		Vector2(WALL_THICKNESS, ROOM_SIZE.y)
	)


func crear_pared(posicion: Vector2, tamano: Vector2) -> void:
	var pared := StaticBody2D.new()
	pared.position = posicion
	add_child(pared)

	var collision := CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	forma.size = tamano
	collision.shape = forma
	pared.add_child(collision)

	var visual := Polygon2D.new()
	var mitad := tamano / 2.0

	visual.polygon = PackedVector2Array([
		Vector2(-mitad.x, -mitad.y),
		Vector2(mitad.x, -mitad.y),
		Vector2(mitad.x, mitad.y),
		Vector2(-mitad.x, mitad.y)
	])

	visual.color = Color(0.12, 0.12, 0.12, 1.0)
	pared.add_child(visual)


# =========================================================
# BOTÓN PARA SALIR
# =========================================================

func crear_boton_salir() -> void:
	var boton := Button.new()
	boton.text = "X"
	boton.position = Vector2(590, 10)
	boton.size = Vector2(35, 35)
	boton.z_index = 10

	add_child(boton)
	boton.pressed.connect(_volver_al_menu)


func _volver_al_menu() -> void:
	_guardar_antes_de_salir()
	get_tree().change_scene_to_file(
		"res://scenes/menu/MainMenu.tscn"
	)

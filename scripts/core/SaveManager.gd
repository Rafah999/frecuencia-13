
extends Node

const SAVE_DIR := "user://saves/"
const PROFILE_PATH := "user://profile.json"
const DEFAULT_GAME_SCENE := "res://scenes/main/TestRoom.tscn"


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(SAVE_DIR)
	)


# =========================================================
# ARCHIVOS JSON
# =========================================================

func _read_json(path: String, fallback: Variant) -> Variant:
	if not FileAccess.file_exists(path):
		return fallback

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return fallback

	var result: Variant = JSON.parse_string(file.get_as_text())
	file.close()

	if result == null:
		return fallback

	return result


func _write_json(path: String, data: Variant) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)

	if file == null:
		push_error("No se pudo escribir el archivo: " + path)
		return false

	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	file.close()
	return true


func _get_save_path(save_id: String) -> String:
	return SAVE_DIR + save_id + ".json"


func _current_datetime() -> String:
	return Time.get_datetime_string_from_system()


# =========================================================
# PROGRESO GENERAL
# =========================================================

func get_profile() -> Dictionary:
	var profile: Variant = _read_json(
		PROFILE_PATH,
		{"unlocked_chapters": [1]}
	)

	if profile is Dictionary:
		return profile

	return {"unlocked_chapters": [1]}


func get_unlocked_chapters() -> Array:
	return get_profile().get("unlocked_chapters", [1])


func unlock_chapter(chapter: int) -> void:
	var profile := get_profile()
	var unlocked: Array = profile.get("unlocked_chapters", [1])

	if not unlocked.has(chapter):
		unlocked.append(chapter)
		unlocked.sort()
		profile["unlocked_chapters"] = unlocked
		_write_json(PROFILE_PATH, profile)


# =========================================================
# CREAR PARTIDA
# =========================================================

func create_save(
	save_name: String,
	chapter: int,
	difficulty: String
) -> Dictionary:
	save_name = save_name.strip_edges()

	if save_name.is_empty():
		return {}

	var save_id := str(
		Time.get_unix_time_from_system()
	) + "_" + str(randi())

	var now := _current_datetime()

	var data: Dictionary = {
		"id": save_id,
		"name": save_name,
		"chapter": chapter,
		"difficulty": difficulty,

		"created_at": now,
		"updated_at": now,
		"last_save_type": "manual",

		"completed": false,
		"play_time_seconds": 0,

		"scene_path": DEFAULT_GAME_SCENE,
		"player_position": {
			"x": 320.0,
			"y": 180.0
		},

		"progress": {
			"objectives_completed": 0,
			"objectives_total": 0
		},

		"decisions": {},
		"telemetry": []
	}

	if not _write_json(_get_save_path(save_id), data):
		return {}

	return data


# =========================================================
# LISTAR PARTIDAS
# =========================================================

func get_saves() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var filenames := DirAccess.get_files_at(SAVE_DIR)

	for filename in filenames:
		if not filename.ends_with(".json"):
			continue

		var path := SAVE_DIR + filename
		var data: Variant = _read_json(path, {})

		if not data is Dictionary:
			continue

		if not data.has("id"):
			continue

		# Compatibilidad con partidas creadas anteriormente.
		if not data.has("play_time_seconds"):
			data["play_time_seconds"] = 0

		if not data.has("scene_path"):
			data["scene_path"] = DEFAULT_GAME_SCENE

		if not data.has("player_position"):
			data["player_position"] = {
				"x": 320.0,
				"y": 180.0
			}

		if not data.has("progress"):
			data["progress"] = {
				"objectives_completed": 0,
				"objectives_total": 0
			}

		if not data.has("last_save_type"):
			data["last_save_type"] = "manual"

		var file := FileAccess.open(path, FileAccess.READ)

		if file != null:
			data["size_bytes"] = file.get_length()
			file.close()
		else:
			data["size_bytes"] = 0

		result.append(data)

	result.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			return str(a.get("updated_at", "")) > str(b.get("updated_at", ""))
	)

	return result


# =========================================================
# CARGAR PARTIDA
# =========================================================

func load_save(save_id: String) -> Dictionary:
	var data: Variant = _read_json(_get_save_path(save_id), {})

	if data is Dictionary and data.has("id"):
		return data

	return {}


# =========================================================
# ACTUALIZAR / GUARDAR PARTIDA
# =========================================================

func update_save(
	save_id: String,
	changes: Dictionary,
	save_type: String = "manual"
) -> bool:
	var data := load_save(save_id)

	if data.is_empty():
		push_error("No existe la partida: " + save_id)
		return false

	for key in changes:
		data[key] = changes[key]

	data["updated_at"] = _current_datetime()
	data["last_save_type"] = save_type

	return _write_json(_get_save_path(save_id), data)


func save_player_state(
	save_id: String,
	scene_path: String,
	player_position: Vector2,
	chapter: int,
	play_time_seconds: int,
	save_type: String = "manual"
) -> bool:
	var changes := {
		"scene_path": scene_path,
		"player_position": {
			"x": player_position.x,
			"y": player_position.y
		},
		"chapter": chapter,
		"play_time_seconds": play_time_seconds
	}

	return update_save(save_id, changes, save_type)


# =========================================================
# ELIMINAR PARTIDA
# =========================================================

func delete_save(save_id: String) -> bool:
	var path := _get_save_path(save_id)

	if not FileAccess.file_exists(path):
		return false

	return DirAccess.remove_absolute(
		ProjectSettings.globalize_path(path)
	) == OK


# =========================================================
# FORMATEAR DATOS
# =========================================================

func format_size(size_bytes: int) -> String:
	if size_bytes < 1024:
		return str(size_bytes) + " B"

	if size_bytes < 1024 * 1024:
		return "%.1f KB" % (float(size_bytes) / 1024.0)

	return "%.2f MB" % (
		float(size_bytes) / (1024.0 * 1024.0)
	)


func format_play_time(total_seconds: int) -> String:
	var hours := int(total_seconds / 3600)
	var minutes := int((total_seconds % 3600) / 60)
	var seconds := total_seconds % 60

	if hours > 0:
		return "%02d h %02d min" % [hours, minutes]

	if minutes > 0:
		return "%02d min %02d s" % [minutes, seconds]

	return "%02d s" % seconds

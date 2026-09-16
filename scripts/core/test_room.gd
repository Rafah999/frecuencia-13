extends Node2D


const ROOM_SIZE := Vector2(640.0, 360.0)
const WALL_THICKNESS := 20.0


func _ready() -> void:
	crear_paredes()


func crear_paredes() -> void:
	# Pared superior
	crear_pared(
		Vector2(ROOM_SIZE.x / 2.0, WALL_THICKNESS / 2.0),
		Vector2(ROOM_SIZE.x, WALL_THICKNESS)
	)

	# Pared inferior
	crear_pared(
		Vector2(ROOM_SIZE.x / 2.0, ROOM_SIZE.y - WALL_THICKNESS / 2.0),
		Vector2(ROOM_SIZE.x, WALL_THICKNESS)
	)

	# Pared izquierda
	crear_pared(
		Vector2(WALL_THICKNESS / 2.0, ROOM_SIZE.y / 2.0),
		Vector2(WALL_THICKNESS, ROOM_SIZE.y)
	)

	# Pared derecha
	crear_pared(
		Vector2(ROOM_SIZE.x - WALL_THICKNESS / 2.0, ROOM_SIZE.y / 2.0),
		Vector2(WALL_THICKNESS, ROOM_SIZE.y)
	)


func crear_pared(posicion: Vector2, tamano: Vector2) -> void:
	# Cuerpo físico de la pared
	var pared := StaticBody2D.new()
	pared.position = posicion
	add_child(pared)

	# Colisión
	var collision := CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	forma.size = tamano

	collision.shape = forma
	pared.add_child(collision)

	# Parte visual
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

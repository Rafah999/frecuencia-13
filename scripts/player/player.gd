extends CharacterBody2D


@export var speed: float = 120.0


func _ready() -> void:
	crear_jugador_temporal()


func crear_jugador_temporal() -> void:
	var polygon := Polygon2D.new()

	polygon.polygon = PackedVector2Array([
		Vector2(-10, -10),
		Vector2(10, -10),
		Vector2(10, 10),
		Vector2(-10, 10)
	])

	polygon.color = Color.WHITE

	add_child(polygon)


func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO

	if Input.is_action_pressed("move_left"):
		direction.x -= 1.0

	if Input.is_action_pressed("move_right"):
		direction.x += 1.0

	if Input.is_action_pressed("move_up"):
		direction.y -= 1.0

	if Input.is_action_pressed("move_down"):
		direction.y += 1.0

	if direction.length() > 0.0:
		direction = direction.normalized()

	velocity = direction * speed

	move_and_slide()

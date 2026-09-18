extends Area2D


@export var interaction_text: String = "Interactuar"


func _ready() -> void:
	crear_radio_temporal()


func crear_radio_temporal() -> void:
	var radio_visual := Polygon2D.new()

	radio_visual.polygon = PackedVector2Array([
		Vector2(-15, -12),
		Vector2(15, -12),
		Vector2(15, 12),
		Vector2(-15, 12)
	])

	radio_visual.color = Color(0.15, 0.15, 0.15, 1.0)

	add_child(radio_visual)


func interact() -> void:
	print("Interacción: ", interaction_text)

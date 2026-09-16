extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exit_button_pressed() -> void:
	get_tree().quit() # Replace with function body.


func _on_new_game_button_mouse_entered() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($CenterContainer/VBoxContainer/MenuButtons/NewGameButton, "scale", Vector2(1.05, 1.05), 0.12)


func _on_new_game_button_mouse_exited() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($CenterContainer/VBoxContainer/MenuButtons/NewGameButton, "scale", Vector2(1.0, 1.0), 0.12)


func _on_continue_button_mouse_entered() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($CenterContainer/VBoxContainer/MenuButtons/ContinueButton, "scale", Vector2(1.05, 1.05), 0.12)


func _on_continue_button_mouse_exited() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($CenterContainer/VBoxContainer/MenuButtons/ContinueButton, "scale", Vector2(1.0, 1.0), 0.12)


func _on_options_button_mouse_entered() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($CenterContainer/VBoxContainer/MenuButtons/OptionsButton, "scale", Vector2(1.05, 1.05), 0.12)


func _on_options_button_mouse_exited() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($CenterContainer/VBoxContainer/MenuButtons/OptionsButton, "scale", Vector2(1.0, 1.0), 0.12)


func _on_exit_button_mouse_entered() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($CenterContainer/VBoxContainer/MenuButtons/ExitButton, "scale", Vector2(1.05, 1.05), 0.12)


func _on_exit_button_mouse_exited() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($CenterContainer/VBoxContainer/MenuButtons/ExitButton, "scale", Vector2(1.0, 1.0), 0.12)

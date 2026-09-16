extends Node

@onready var intro_animation: AnimationPlayer = $IntroLayer/Intro/IntroAnimation


func _ready() -> void:
	intro_animation.play("Intro")
	await intro_animation.animation_finished
	
	get_tree().change_scene_to_file("res://scenes/menu/MainMenu.tscn")

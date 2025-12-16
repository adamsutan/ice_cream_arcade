extends Control

func _ready() -> void:
	if get_tree().paused != false:
		get_tree().paused = false

func _on_rush_pressed() -> void:
	Global.difficulty = "rush"
	get_tree().change_scene_to_file("res://game.tscn")


func _on_relax_pressed() -> void:
	Global.difficulty = "relax"
	get_tree().change_scene_to_file("res://game.tscn")

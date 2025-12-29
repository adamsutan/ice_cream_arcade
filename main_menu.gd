extends Control
@onready var sfx_menu: AudioStreamPlayer = $sfx_menu

func _ready() -> void:
	if get_tree().paused != false:
		get_tree().paused = false

func _on_rush_pressed() -> void:
	sfx_menu.play()
	await get_tree().create_timer(0.5).timeout
	Global.difficulty = "rush"
	Global.reset_score()
	get_tree().change_scene_to_file("res://game.tscn")


func _on_relax_pressed() -> void:
	sfx_menu.play()
	await get_tree().create_timer(0.5).timeout
	Global.difficulty = "relax"
	get_tree().change_scene_to_file("res://game.tscn")

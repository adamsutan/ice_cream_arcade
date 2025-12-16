extends Control
func _ready() -> void:
	$AnimationPlayer.play("RESET")
	visible = false
	# Make sure UI receives input while the tree is paused

func resume() -> void:
	$AnimationPlayer.play_backwards("blur")
	# Unpause first (notification will hide), then ensure visible = false
	get_tree().paused = false
	visible = false
	Global.pause_instance = null

func pause() -> void:
	# Show UI then pause the tree (notification will call show() too)
	visible = true
	$AnimationPlayer.play("blur")
	get_tree().paused = true

func _on_continue_pressed() -> void:
	resume()

func _on_main_menu_pressed() -> void:
	visible = false
	Global.pause_instance = null
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

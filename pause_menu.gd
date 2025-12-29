extends Control
@onready var sfx_pause: AudioStreamPlayer = $sfx_pause
@onready var sfx_resume: AudioStreamPlayer = $sfx_resume
@onready var sfx_main_menu: AudioStreamPlayer = $sfx_main_menu
@onready var sfx_exit: AudioStreamPlayer = $sfx_exit

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
	sfx_pause.play()
	visible = true
	$AnimationPlayer.play("blur")
	get_tree().paused = true

func _on_continue_pressed() -> void:
	sfx_resume.play()
	resume()

func _on_main_menu_pressed() -> void:
	sfx_main_menu.play()
	visible = false
	Global.pause_instance = null
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_exit_pressed() -> void:
	sfx_exit.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

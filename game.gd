extends Node2D

@onready var vanilla_scene = preload("res://vanilla_scoop.tscn")
@onready var strawberry_scene = preload("res://strawberry_scoop.tscn")
@onready var chocolate_scene = preload("res://chocolate_scoop.tscn")

@onready var scoop_container = $"ice cream display/scoop currently"
var scoop_count = 0
var scoop_spacing = -30


func _on_vanilla_pressed() -> void:
	add_scoop(vanilla_scene)



func _on_strawberry_pressed() -> void:
	add_scoop(strawberry_scene)



func _on_chocolate_pressed() -> void:
	add_scoop(chocolate_scene)

func add_scoop(scoop_scene: PackedScene) -> void:
	if scoop_count >= 3 :
		return #
	var scoop = scoop_scene.instantiate()   # <-- this line belongs to add_scoop
	scoop.position = Vector2(0, scoop_spacing * scoop_count)
	scoop_container.add_child(scoop)
	scoop_count += 1


func _on_cone_pressed() -> void:
	for scoop in scoop_container.get_children():
		scoop.queue_free()
	scoop_count = 0

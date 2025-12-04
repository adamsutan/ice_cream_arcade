extends Node2D
@onready var male_customer_scene = preload("res://customer_m.tscn")
@onready var female_customer_scene = preload("res://customer_f.tscn")
@onready var vanilla_scene = preload("res://vanilla_scoop.tscn")
@onready var strawberry_scene = preload("res://strawberry_scoop.tscn")
@onready var chocolate_scene = preload("res://chocolate_scoop.tscn")
@onready var Banana_scene = preload("res://banana_scoop.tscn")
@onready var green_tea_scene = preload("res://green_tea_scoop.tscn")
@onready var red_velvet_scene = preload("res://red_velvet_scoop.tscn")
@onready var timer = $Timer
@onready var time_label: RichTextLabel = $TimerDisplay
@onready var order_debug: RichTextLabel = $Order
@onready var scoop_container = $"ice cream display/scoop currently"

var current_customer = null
var scoop_count = 0
var scoop_spacing = -30

var avail_scoops: Array = [1,2,3,4,5,6] #kode buat rasa in case mau tambah rasa
var order: Array = []
var serve: Array = []

func _ready() -> void:
	generate_order()

func _process(_delta: float) -> void:
	# Timer
	if timer.is_stopped():
		time_label.text = "[0.0 s]"
	else:
		time_label.text = "[%.1f s]" % timer.time_left
	
	order_debug.text = str(order)
	
	if serve == order:
		on_serve_match()

func on_serve_match() -> void:
	timer.wait_time = 10.0
	timer.start()
	await get_tree().create_timer(0.5).timeout
	for scoop in scoop_container.get_children():
		scoop.queue_free()
	scoop_count = 0
	serve = []
	generate_order()
	
#func spawn_customer():
	#var choice = randi() % 2
	#if choice == 0:
		#current_customer = male_customer_scene.instantiate()
	#else:
		#current_customer = female_customer_scene.instantiate()
	#current_customer.position = Vector2(300, 200)  # Adjust to shop layout
	#add_child(current_customer)
	#current_customer.start_order()

func generate_order():
	var max_scoop = 3
	var min_scoop = 1
	var count = randi() % (max_scoop - min_scoop + 1) + min_scoop
	var shuffled = avail_scoops.duplicate()
	# Fisher-Yates shuffle
	for i in range(shuffled.size() - 1, 0, -1):
		var j = randi() % (i + 1)
		var tmp = shuffled[i]
		shuffled[i] = shuffled[j]
		shuffled[j] = tmp
	# Pilih count teratas (slice) hasil shuffle jadi order
	order = shuffled.slice(0, count)

func _on_vanilla_pressed() -> void:
	add_scoop(vanilla_scene)
	serve.append(2)

func _on_strawberry_pressed() -> void:
	add_scoop(strawberry_scene)
	serve.append(3)

func _on_chocolate_pressed() -> void:
	add_scoop(chocolate_scene)
	serve.append(1)

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
	serve = []

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://game_over.tscn")
	# nanti bikin scene game_over trus panggil disini

func _on_red_velvet_pressed() -> void:
	add_scoop(red_velvet_scene)
	serve.append(6)


func _on_green_tea_pressed() -> void:
	add_scoop(green_tea_scene)
	serve.append(5)


func _on_banana_pressed() -> void:
	add_scoop(Banana_scene)
	serve.append(4)

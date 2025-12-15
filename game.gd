extends Node2D

# Customer scenes (exported so you can override in the Inspector, with sensible defaults)
@export var male_customer_scene: PackedScene = preload("res://customer_m.tscn")
@export var female_customer_scene: PackedScene = preload("res://customer_f.tscn")

# Scoop scenes (exported so designer dapat drag & drop di Inspector; default preloads disediakan)
@export var vanilla_scene: PackedScene = preload("res://vanilla_scoop.tscn")
@export var strawberry_scene: PackedScene = preload("res://strawberry_scoop.tscn")
@export var chocolate_scene: PackedScene = preload("res://chocolate_scoop.tscn")
@export var banana_scene: PackedScene = preload("res://banana_scoop.tscn")
@export var green_tea_scene: PackedScene = preload("res://green_tea_scoop.tscn")
@export var red_velvet_scene: PackedScene = preload("res://red_velvet_scoop.tscn")

@onready var timer = $Timer
@onready var time_label: RichTextLabel = $TimerDisplay
@onready var order_debug: RichTextLabel = $Order
@onready var scoop_container = $"IceCreamDisplay/scoop_currently"
@onready var customer_position = $"CustomerDisplay"

# pause variable (for editing kalau mau)
var PauseMenu = preload("res://pause_menu.tscn")
var pause_instance = null

# Path (relative to this node) to the node that should contain order scoops.
# Sesuaikan kalau struktur scene root-mu beda. Default sesuai screenshotmu.
@export var order_scoops_rel_path: String = "OrderDisplay/order_scoops" 

# Visual tweaks untuk order display (Inspector-friendly)
@export var order_scoop_scale: Vector2 = Vector2(0.1, 0.1)
@export var order_scoop_spacing = -30.0

var current_customer = null
var scoop_count = 0
var scoop_spacing: float = -30.0
var order_served = 0

var scoop_map: Dictionary = {}
var tray_position: Dictionary = {}

var avail_scoops: Array = []
var order: Array = []
var serve: Array = []
var is_serving: bool = false

func _ready() -> void:
	scoop_map = {
		1: chocolate_scene,
		2: vanilla_scene,
		3: strawberry_scene,
		4: banana_scene,
		5: green_tea_scene,
		6: red_velvet_scene
	}
	
	tray_position = {
		1: {
			"name" : $Chocolate,
			"position": [$Chocolate.position.x, $Chocolate.position.y]
		},
		2: {
			"name" : $Vanilla,
			"position": [$Vanilla.position.x, $Vanilla.position.y]
		},
		3: {
			"name" : $Strawberry,
			"position": [$Strawberry.position.x, $Strawberry.position.y]
		},
		4: {
			"name" : $Banana,
			"position": [$Banana.position.x, $Banana.position.y]
		},
		5: {
			"name" : $Green_Tea,
			"position": [$Green_Tea.position.x, $Green_Tea.position.y]
		},
		6: {
			"name" : $Red_Velvet,
			"position": [$Red_Velvet.position.x, $Red_Velvet.position.y]
		}
	}
	
	avail_scoops = scoop_map.keys()
	randomize()
	
	# Setup berdasarkan difficulty
	if Global.difficulty == "rush":
		timer.wait_time = 10.0
		timer.start()
		time_label.visible = true
	else:
		timer.stop()
		time_label.visible = false  

	generate_order()
	spawn_customer()
	display_order_in_bubble(order)

func _process(_delta: float) -> void:
	# Update timer display (cuma di rush mode)
	if Global.difficulty == "rush":
		if timer.is_stopped():
			time_label.text = "[0.0 s]"
		else:
			time_label.text = "[%.1f s]" % timer.time_left

	order_debug.text = str(order)

	if serve == order and serve.size() > 0 and not is_serving:
		is_serving = true
		on_serve_match()

func on_serve_match() -> void:
	order_served += 1
	
	# Restart timer cuma di rush mode
	if Global.difficulty == "rush":
		timer.wait_time = 10.0
		timer.start()

	await get_tree().create_timer(0.5).timeout

	# bersihkan scoop yang ada pada player
	for scoop in scoop_container.get_children():
		scoop.queue_free()
	scoop_count = 0
	serve = []

	# bersihkan customer(s)
	for c in customer_position.get_children():
		c.queue_free()
	current_customer = null
	
	clear_order_bubble()
	
	if order_served >= 10:
		shuffle_tray_positions()
	
	generate_order()
	spawn_customer()
	display_order_in_bubble(order)
	is_serving = false

func shuffle_tray_positions() -> void:
	# Ambil semua posisi dari tray_position dictionary
	var positions: Array = []
	for key in tray_position.keys():
		positions.append(tray_position[key]["position"].duplicate())
	
	# Shuffle array posisi menggunakan Fisher-Yates shuffle
	for i in range(positions.size() - 1, 0, -1):
		var j = randi() % (i + 1)
		var tmp = positions[i]
		positions[i] = positions[j]
		positions[j] = tmp
	
	# Assign posisi yang sudah diacak ke masing-masing node
	var idx = 0
	for key in tray_position.keys():
		var node = tray_position[key]["name"]
		if node != null:
			node.position = Vector2(positions[idx][0], positions[idx][1])
			# Update posisi di dictionary juga (untuk tracking)
			tray_position[key]["position"] = positions[idx]
		idx += 1

func spawn_customer():
	var choice = randi() % 2
	if choice == 0:
		current_customer = male_customer_scene.instantiate()
	else:
		current_customer = female_customer_scene.instantiate()
	customer_position.add_child(current_customer)

func generate_order():
	var max_scoop = 3
	var min_scoop = 1
	var count = randi() % (max_scoop - min_scoop + 1) + min_scoop

	var shuffled = avail_scoops.duplicate()
	for i in range(shuffled.size() - 1, 0, -1):
		var j = randi() % (i + 1)
		var tmp = shuffled[i]
		shuffled[i] = shuffled[j]
		shuffled[j] = tmp

	order = shuffled.slice(0, count)

func add_scoop_by_scene(scoop_scene: PackedScene) -> void:
	if scoop_count >= 3:
		return
	if scoop_scene == null:
		push_error("Tried to add null scoop scene")
		return
	var scoop = scoop_scene.instantiate()
	scoop.position = Vector2(0, scoop_spacing * scoop_count)
	scoop_container.add_child(scoop)
	scoop_count += 1

func add_scoop_by_code(code: int) -> void:
	var scene = scoop_map.get(code, null)
	if scene == null:
		push_error("No scoop scene mapped for code: %s" % str(code))
		return
	add_scoop_by_scene(scene)

# dari root script (get_node_or_null(order_scoops_rel_path)) dan menambahkan scoop preview.
func display_order_in_bubble(order_arr: Array) -> void:
	var container: Node = get_node_or_null(order_scoops_rel_path)
	if container == null:
		push_warning("Order display node not found at path '%s'. Adjust order_scoops_rel_path." % order_scoops_rel_path)
		return

	# kosongkan dulu
	for child in container.get_children():
		child.queue_free()

	var n = order_arr.size()
	for i in range(n):
		var code = order_arr[i]
		var scene = scoop_map.get(code, null)
		if scene == null:
			continue
		var ordered_scoops_texture = scene.instantiate()
		# ini jadi initiate child baru di dalam order_scoops
		ordered_scoops_texture.scale = order_scoop_scale
		# ini biar... ohh scaling texture scoop es krim nya biar es krim muat di texture bubble order
		# posisi relatif terhadap container; letakkan agar tumpukan terlihat di atas cone
		# index 0 -> scoop paling bawah, jadi pos Y = spacing * i
		ordered_scoops_texture.position = Vector2(0, order_scoop_spacing * i)
		# atur z_index supaya scoops yang lebih atas digambar di atas
		if ordered_scoops_texture is Node2D:
			ordered_scoops_texture.z_index = i
		container.add_child(ordered_scoops_texture)
		#ini nambahin scoop terus terusan pokoknya aowkwkwkwk
		#sumpahh ini function ribet batt anjirrr

func clear_order_bubble() -> void:
	var container: Node = get_node_or_null(order_scoops_rel_path)
	if container == null:
		return
	for child in container.get_children():
		child.queue_free()

func _on_cone_pressed() -> void:
	for scoop in scoop_container.get_children():
		scoop.queue_free()
	scoop_count = 0
	serve = []
	# optionally clear order preview when player clears cone
	# clear_order_bubble()

func _on_timer_timeout() -> void:
	if Global.difficulty == "rush":
		get_tree().change_scene_to_file("res://game_over.tscn")

# ------------------------------------------------- Tempat scoop2 (boring) --------------------------------#

func _on_vanilla_pressed() -> void:
	add_scoop_by_code(2)
	serve.append(2)

func _on_strawberry_pressed() -> void:
	add_scoop_by_code(3)
	serve.append(3)

func _on_chocolate_pressed() -> void:
	add_scoop_by_code(1)
	serve.append(1)

func _on_red_velvet_pressed() -> void:
	add_scoop_by_code(6)
	serve.append(6)

func _on_green_tea_pressed() -> void:
	add_scoop_by_code(5)
	serve.append(5)

func _on_banana_pressed() -> void:
	add_scoop_by_code(4)
	serve.append(4)

func _on_pause_pressed() -> void:
	print("pause is pressed")
	if pause_instance == null or not pause_instance.is_inside_tree():
		pause_instance = PauseMenu.instantiate()
		get_tree().root.add_child(pause_instance)
		pause_instance.pause()

extends Node2D
var	object_spawn_point_1 
var	object_spawn_point_2  
var	object_spawn_point_3  
var enemy_1 : PackedScene = load("res://enemy_1.tscn")
var enemy_2 : PackedScene = load("res://enemy_2.tscn")
var enemy_3 : PackedScene = load("res://enemy_3.tscn")
var object_spawn_points = []
var possible_objects = [enemy_1, enemy_2, enemy_3]
var spawned_objects = []
var barrier_1 : PackedScene = load("res://barrier_1.tscn")
var barrier_2 : PackedScene = load("res://barrier_2.tscn")
var none : PackedScene = load("res://barrier_1.tscn")
var barriers = [barrier_1, barrier_2]
var left_barriers = []
var right_barriers = []
var difficulty = 10.0
var left_create : bool
var right_create : bool
var barrier_space = 200
var last_left_difference = 0
var last_right_difference = 0
var initial_vert_control_position
var vert_control_hold = false
var vert_direction : String
var player_vert_speed = 10 
var object_speed = 5
var screen 
var side_delayed : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	left_create = bool(randi() % 2)
	right_create = not left_create
	
	initial_vert_control_position = $player_vert_control.position
	object_spawn_point_1 = $obstacle_spawnpoint_1
	object_spawn_points.append(object_spawn_point_1)
	object_spawn_point_2 = $obstacle_spawnpoint_2
	object_spawn_points.append(object_spawn_point_2)
	object_spawn_point_3 = $obstacle_spawnpoint_3
	object_spawn_points.append(object_spawn_point_3)
	create_objects()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	for object in spawned_objects:
		if "enemy" not in object.name:
			object.position.y -= object_speed
		else:
			if object.special_action == false:
				object.position.y -= object_speed
				
	for barrier in left_barriers:
		barrier.position.y -= 80 * delta
	for barrier in right_barriers:
		barrier.position.y -= 80 * delta
	if left_create:
		left_barrier_spawn(difficulty)
		left_create = false
	elif right_create:
		right_barrier_spawn(difficulty)
		right_create = false
		
	# button held
	if $player_vert_control.is_pressed() :
		vert_control_hold = true
	else:
		vert_control_hold = false
	
	if vert_control_hold:
		$player_vert_control.position.y = get_global_mouse_position().y
		if $player_vert_control.position.y > initial_vert_control_position.y:
			vert_direction = "down"
		if $player_vert_control.position.y < initial_vert_control_position.y:
			vert_direction = "up"
	player_vert_movement(vert_direction)
		
func player_vert_movement(direction):
	if direction == "down":
		$player.position.y += player_vert_speed
	if direction == "up":
		$player.position.y -= player_vert_speed
	
# left side spawns
func left_barrier_spawn(difficulty):
	var left_barrier = barriers[randi() % barriers.size()].instantiate()
	if left_barrier != none:
		left_barrier.name = "left_barrier"
		left_barriers.append(left_barrier)
		add_child(left_barrier)
		var left_height = left_barrier.get_node("Sprite2D").texture.get_height()
		if last_left_difference == 0:
			left_barrier.position = $left_barrier_spawner.position

		else:
			left_barrier.position = $left_barrier_spawner.position 
			left_barrier.position.y += last_left_difference
			left_barrier.position.y += barrier_space
			
			
		last_left_difference = left_height
	if right_create == true:
		var left_timer = Timer.new()
		left_timer.wait_time = difficulty
		left_timer.one_shot = true
		left_timer.timeout.connect(left_timer_timeout)
		add_child(left_timer)
		left_timer.start()
	else:
		
		side_delayed = "left"
		delay(difficulty)

	
	
func left_timer_timeout():
	left_create = true
# right side spawns
func right_barrier_spawn(difficulty):
	var right_barrier = barriers[randi() % barriers.size()].instantiate()
	right_barrier.name = "right_barrier"
	right_barriers.append(right_barrier)
	right_barrier.get_node("Sprite2D").flip_h = true
	add_child(right_barrier)
	var right_height = right_barrier.get_node("Sprite2D").texture.get_height()
	if last_right_difference == 0:
		right_barrier.position = $right_barrier_spawner.position

	else:
		right_barrier.position = $right_barrier_spawner.position 
		right_barrier.position.y += last_right_difference
		right_barrier.position.y += barrier_space
	if left_create == true:
		last_right_difference = right_height
		var right_timer = Timer.new()
		right_timer.wait_time = difficulty
		right_timer.one_shot = true
		right_timer.timeout.connect(right_timer_timeout)
		add_child(right_timer)
		right_timer.start()
	else:
		side_delayed = "right"
		delay(difficulty)
func right_timer_timeout():
	right_create = true


func _on_player_vert_control_pressed() -> void:
	pass
	#$player_vert_control.position.y = get_global_mouse_position().y
	


func _on_player_vert_control_released() -> void:
	$player_vert_control.position = initial_vert_control_position
func create_objects():
	var object = possible_objects[randi() % possible_objects.size()].instantiate()
	var spawn_point = object_spawn_points.pick_random()
	object.position = spawn_point.position

	spawned_objects.append(object)
	add_child(object)
	var creation_cooldown_time = randi_range(2.0, 10.0)
	var creation_cooldown = Timer.new()
	creation_cooldown.one_shot = true
	creation_cooldown.wait_time = creation_cooldown_time
	creation_cooldown.timeout.connect(creation_cooldown_timeout)
	add_child(creation_cooldown)
	creation_cooldown.start()
func creation_cooldown_timeout():
	create_objects()
func delay(difficulty):
	var delay_timer = Timer.new()
	delay_timer.wait_time = difficulty/3
	delay_timer.one_shot = true
	delay_timer.timeout.connect(delay_timeout)
	add_child(delay_timer)
	delay_timer.start()
func delay_timeout():
	match side_delayed:
		"left":
			right_create = true
			
		"right":
			left_create = true
		_:
			pass
	
	
	
	
	


func _on_left_bound_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		global.health = 0


func _on_right_bound_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		global.health = 0

extends Node2D
var ejected_rider : PackedScene = load("res://ejected_rider.tscn")
var player_death_effect : PackedScene = load("res://explosion_effect.tscn")
var main_scroll_speed = 50
var background_sprites = []
var background_start_pos
var bg_height 
var	object_spawn_point_1 
var	object_spawn_point_2  
var	object_spawn_point_3  
var upgrade_crate : PackedScene = load("res://upgrade_crate.tscn")
var trash : PackedScene = load("res://trash.tscn")
var enemy_1 : PackedScene = load("res://enemy_1.tscn")
var enemy_2 : PackedScene = load("res://enemy_2.tscn")
var enemy_3 : PackedScene = load("res://enemy_3.tscn")
var enemy_4 : PackedScene = load("res://enemy_4.tscn")
var other_vehicle : PackedScene = load("res://vehicle.tscn")
var hori_shift_fuel : PackedScene = load("res://hori_shift_fuel.tscn")
var object_spawn_points = []
var possible_objects = [other_vehicle, enemy_1, enemy_2, enemy_3, enemy_4, upgrade_crate, trash, hori_shift_fuel, other_vehicle]
var barrier_1 : PackedScene = load("res://barrier_1.tscn")
var barrier_2 : PackedScene = load("res://barrier_2.tscn")
var barrier_3 : PackedScene = load("res://barrier_3.tscn")
var barrier_4 : PackedScene = load("res://barrier_4.tscn")
var none : PackedScene = load("res://barrier_1.tscn")
var barriers = [barrier_1, barrier_2, barrier_3, barrier_1, barrier_1, barrier_4]
var barrier_heights = [636.0,411.0, 230.0, 96.0]

var left_create : bool
var right_create : bool
var barrier_space = 400
var last_left_difference=0
var last_right_difference = 0
var initial_vert_control_position
var vert_control_hold = false
var vert_direction : String
var player_vert_speed = 10 
var screen_size
var screen_y
var side_delayed : String
var initial_camera
var create = false
var difficulty = global.difficulty
var object_speed = 150
var game_start : bool
var right_count = 0
var left_count = 0
var add_left_count = true
var add_right_count = true
var can_spawn_barrier = true
var latest_right_barrier
var latest_left_barrier
var can_left_create = true
var can_right_create = true



# update_score
var can_update = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global.health = 2
	global.death = false
	$player.visible = true
	global.current_barriers = []
	global.left_barriers = []
	global.right_barriers = []
	global.spawned_objects = []
	print("layer_1 lower pos", $backgrounds/layer_1/lower_point.global_position.y)
	for layer in $backgrounds.get_children():
		if layer.name.contains("copy") == false:
			layer.global_position = Vector2(0,0)
			
		match layer.name:
			"layer_1":
				var layer_1_copy = layer.duplicate()
				layer_1_copy.global_position = Vector2(layer.global_position.x, get_viewport_rect().size.y)
				layer_1_copy.name = "layer_1_copy"
				$backgrounds.add_child(layer_1_copy)
			"layer_2":
				var layer_2_copy = layer.duplicate()
				layer_2_copy.global_position = Vector2(layer.global_position.x, layer.get_node("lower_point").global_position.y)
				layer_2_copy.name = "layer_2_copy"
				$backgrounds.add_child(layer_2_copy)
				print("layer 2 copy created")
			"layer_3":
				var layer_3_copy = layer.duplicate()
				layer_3_copy.global_position = Vector2(layer.global_position.x, layer.get_node("lower_point").global_position.y)
				layer_3_copy.name = "layer_3_copy"
				$backgrounds.add_child(layer_3_copy)
	global.stored_coins = 1000
	global.score = 0
	global.gathered_coins = 0
	last_left_difference = 0
	last_right_difference = 0
	var door_timer = Timer.new()
	door_timer.wait_time = 0.39
	door_timer.one_shot = true
	door_timer.timeout.connect(door_timeout)	
	add_child(door_timer)
	door_timer.start()
	$player.modulate = 0
	$AnimationPlayer.play("start_game")
	global.immunity_time(3.0)
	$barrier_control_timer.start()
	
	
	
	initial_camera = $Camera2D.position
	screen_size = get_viewport().get_visible_rect().size
	game_start = true
	if $player.hori_direction == "left":
		left_create = true
		left_barrier_spawn(difficulty)
	if $player.hori_direction == "right":
		right_create = true
		right_barrier_spawn(difficulty)
	initial_vert_control_position = $player_vert_control.position
	object_spawn_point_1 = $obstacle_spawnpoint_1
	object_spawn_points.append(object_spawn_point_1)
	object_spawn_point_2 = $obstacle_spawnpoint_2
	object_spawn_points.append(object_spawn_point_2)
	object_spawn_point_3 = $obstacle_spawnpoint_3
	object_spawn_points.append(object_spawn_point_3)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global.current_barriers.size() > 9:
		print("current barriers !!!!!!!!!!!!!!!!!!!!!!!!!!!", global.current_barriers.size())
	if global.spawned_objects.size() > 8:
		print("current spawned object@!!!!!!!!!!!!!!!!!!!!!!11 ", global.spawned_objects.size())
	for layer in $backgrounds.get_children():
		var speed = 100
		if layer.name.contains("1"):
			speed = 100
			layer.position.y -= speed * delta
		if layer.name.contains("2"):
			speed = 150
			layer.position.y -= speed * delta
		if layer.get_node("lower_point").global_position.y <= 0:
			layer.global_position.y = 640
			
	if global.death:
		var vehicle_explosion = player_death_effect.instantiate()
		vehicle_explosion.position = $player.global_position
		vehicle_explosion.subject = "player"
		var rider = ejected_rider.instantiate()
		rider.position = $player.position
		add_child(vehicle_explosion)
		add_child(rider)
		global.death = false
	if global.health > 0 and is_instance_valid($player) and $player.can_move == true:
		global.update_difficulty()
		update_score(difficulty)
		if $up_button.is_pressed():
			global.go_up = true
		if $down_button.is_pressed():
			global.go_down = true
		if $player_attack_button.is_pressed():
			global.player_attack = true
		if $shift_button.is_pressed():
			global.shift = true
	if $player.can_move == true:
		game_start = false
	else:
		game_start = true
	if game_start == false:
		global.game_started = true
		if global.current_barriers.size() > 7:
			can_spawn_barrier = false
		if global.current_barriers.size() < 8:
			can_spawn_barrier = true
	#print("------------------------------------current count: ", current_barriers.size())
	
		

		
		
	# button held
	if $player_vert_control.is_pressed() :
		vert_control_hold = true
	else:
		vert_control_hold = false
	
	if vert_control_hold:
		$player_vert_control.position.y = get_global_mouse_position().y
		if $player_vert_control.position.y > initial_vert_control_position.y:
			global.go_down = true
			global.go_up = false
		if $player_vert_control.position.y < initial_vert_control_position.y:
			global.go_up = true
			global.go_down = false
	else:
		$player_vert_control.position.y = initial_vert_control_position.y
		
		
	player_vert_movement(vert_direction)
		
func player_vert_movement(direction):
	if direction == "down":
		$player.position.y += player_vert_speed
	if direction == "up":
		$player.position.y -= player_vert_speed
# left side spawns
func left_barrier_spawn(difficulty):
	#var cluster : bool
	#var seperation 
	if can_spawn_barrier:
		if left_create:
			if game_start:
				var left_barrier = barriers[randi() % barriers.size()].instantiate()
				left_barrier.can_create_enemy = false
				left_barrier.name = "left_barrier"
				add_child(left_barrier)
				global.current_barriers.append(left_barrier)
				global.left_barriers.append(left_barrier)
				#seperation += left_barrier.get_node("CollisionShape2D").shape.size.y
				left_barrier.global_position.x = $left_barrier_spawner.global_position.x
				left_barrier.global_position.y = $player.global_position.y + 200
				left_create = false
			if global.left_barriers.size() < 3 and game_start == false:
				var left_barrier = barriers[randi() % barriers.size()].instantiate()
				left_barrier.name = "left_barrier"
				add_child(left_barrier)
				global.current_barriers.append(left_barrier)
				global.left_barriers.append(left_barrier)
				latest_left_barrier = left_barrier

				left_barrier.global_position = $left_barrier_spawner.global_position 
				if get_node("left_barrier").is_visible_in_tree():
					left_barrier.global_position = $left_barrier_spawner.global_position 
					left_barrier.global_position.y += left_barrier.get_node("CollisionShape2D").shape.size.y
				left_create = false
	side_delayed = "left"
	delay(difficulty)
	#count_spawned_objects()
	#barrier_deletion()
	#barrier_control()
func right_barrier_spawn(difficulty):
	if can_spawn_barrier:
		if right_create:
			if game_start:
				var right_barrier = barriers[randi() % barriers.size()].instantiate()
				right_barrier.can_create_enemy = false
				right_barrier.name = "right_barrier"
				right_barrier.get_node("AnimatedSprite2D").flip_h = true
				var right_height = right_barrier.get_node("CollisionShape2D").shape.size.y
				right_barrier.global_position.x = $right_barrier_spawner.global_position.x
				right_barrier.global_position.y = $player.global_position.y + 200
				add_child(right_barrier)
				global.current_barriers.append(right_barrier)
				global.right_barriers.append(right_barrier)
				last_right_difference = right_height
				right_create = false
				
			if global.right_barriers.size() < 3 and game_start == false:
				var right_barrier = barriers[randi() % barriers.size()].instantiate()
				right_barrier.name = "right_barrier"
				right_barrier.get_node("AnimatedSprite2D").flip_h = true
				add_child(right_barrier)
				global.current_barriers.append(right_barrier)
				global.right_barriers.append(right_barrier)
				latest_right_barrier = right_barrier			
				right_barrier.global_position = $right_barrier_spawner.global_position
				if latest_right_barrier.is_visible_in_tree():
					right_barrier.global_position = $right_barrier_spawner.global_position 
					right_barrier.global_position.y += right_barrier.get_node("CollisionShape2D").shape.size.y
					right_create = false
	side_delayed = "right"
	delay(difficulty)
	#count_spawned_objects()
	#barrier_deletion()
	#barrier_control()
func count_spawned_objects():
	
	var object_count = 0
	for object in global.spawned_objects:
		object_count += 1
	if object_count > 2:
		print("current amount of spawned obejcts is --------------------- : ", object_count)
func barrier_control():
	left_count = 0
	right_count = 0
	for barrier in global.left_barriers:
		if is_instance_valid(barrier):
			if barrier.global_position.y >= 0 and barrier.global_position.y <= 700:
				left_count += 1
		else:
			global.left_barriers.erase(barrier)
	if left_count < 2 and can_spawn_barrier:
		if can_left_create:
			left_barrier_spawn(difficulty)
			can_left_create = false
	for barrier in global.right_barriers:
		if is_instance_valid(barrier):
			if barrier.global_position.y >= 0 and barrier.global_position.y <= 700:
				right_count += 1
		else:
			global.right_barriers.erase(barrier)
	if right_count < 2 and can_spawn_barrier:
		if can_right_create:
			right_barrier_spawn(difficulty)
			can_right_create = false
	$barrier_control_timer.start()
func clear_spawned_objects():
	pass
func clear_spawned_barriers():
	pass
func _on_player_vert_control_pressed() -> void:
	pass
	#$player_vert_control.position.y = get_global_mouse_position().y
func _on_player_vert_control_released() -> void:
	$player_vert_control.position = initial_vert_control_position
func create_objects():
	if create:
		var vehicle_spawn_points = [object_spawn_point_1, object_spawn_point_3]
		var object = possible_objects[randi() % possible_objects.size()].instantiate()
		if object.name.contains("vehicle"):
			var spawn_point = vehicle_spawn_points.pick_random()
			object.position = spawn_point.position
			if spawn_point == object_spawn_point_3:
				object.position.x = object_spawn_point_3.global_position.x
				object.position.y = object_spawn_point_3.global_position.y
				object.lane = "right"
				global.spawned_objects.append(object)
			if spawn_point == object_spawn_point_1:
				object.position.x = object_spawn_point_1.global_position.x
				object.position.y = object_spawn_point_1.global_position.y - get_viewport_rect().size.y - object.get_node("CollisionShape2D").shape.size.y
				object.lane = "left"
				global.spawned_objects.append(object)
				
			
		else:
			var spawn_point = object_spawn_points.pick_random()
			object.position = spawn_point.position
		global.spawned_objects.append(object)
				
		add_child(object)
		var creation_cooldown_time = randi_range(2.0, 10.0)
		var creation_cooldown = Timer.new()
		creation_cooldown.one_shot = true
		creation_cooldown.wait_time = creation_cooldown_time
		creation_cooldown.timeout.connect(creation_cooldown_timeout)
		add_child(creation_cooldown)
		creation_cooldown.start()
	object_deletion()
func creation_cooldown_timeout():
	create_objects()
func delay(difficulty):
	right_create = false
	left_create = false
	var delay_timer = Timer.new()
	if game_start:
		delay_timer.wait_time = 0.5 
	if game_start == false:
		delay_timer.wait_time = difficulty/3
	delay_timer.one_shot = true
	delay_timer.timeout.connect(delay_timeout)
	add_child(delay_timer)
	delay_timer.start()
func delay_timeout():
	match side_delayed:
		"left":
			can_left_create = false
			right_create = true
			right_barrier_spawn(difficulty)
			if game_start:
				game_start = false
			can_right_create = true
			
		"right":
			can_right_create = false
			left_create = true
			left_barrier_spawn(difficulty)
			if game_start:
				game_start = false
			can_left_create = true
		_:
			pass
	
func _on_left_bound_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		global.health = 0
	if body.has_method("enemy"):
		pass
func _on_right_bound_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
			global.health = 0
	if body.has_method("enemy"):
		pass
func object_deletion():
	for object in global.spawned_objects:
		if is_instance_valid(object) == false:
			global.spawned_objects.erase(object)
	for object in global.spawned_objects:
		if is_instance_valid(object):
			if object.name.contains("vehicle"):
				if object.lane == "left" and position.y > 800:
					object.queue_free()
					global.spawned_objects.erase(object)
				if object.lane == "right" and position.y < -100:
					object.queue_free()
					global.spawned_object.erase(object)
		else:
			global.spawned_objects.erase(object)
	
	for body in $enemy_border.get_overlapping_bodies():
		if "enemy" in body.name and body in global.spawned_objects:
			if "vehicle" not in body.name:
				global.spawned_objects.erase(body)
				body.queue_free()
	for object in global.spawned_objects:
		var offset = 100 #base offset that is added to be the height of the object
		if is_instance_valid(object.get_node("CollisionShape2D")):
			if object.get_node("CollisionShape2D").shape == CircleShape2D:
				offset += object.get_node("CollisionShape2D").shape.radius * 2
			if object.get_node("CollisionShape2D").shape == RectangleShape2D:
				offset += object.get_node("CollisionShape2D").shape.size.y
		else:
			offset = 200
		if is_instance_valid(object) and not object.name.contains("vehicle"):
			if not object.position.y <= get_viewport_rect().size.y + offset and object.position.y >= 0 - offset:
				object.queue_free()
				global.spawned_objects.erase(object)
			if not object.position.x <= get_viewport_rect().size.x and object.position.x >= 0:
				object.queue_free()
				global.spawned_objects.erase(object)
		else:
			if object.name.contains("vehicle"):
				if object.lane == "left":
					if object.position.y > get_viewport_rect().size.y + object.get_node("CollisionShape2D").shape.size.y:
						object.queue_free()
						global.spawned_objects.erase(object)
				if object.lane == "right":
					if object.position.y < 0 - object.get_node("CollisionShape2D").shape.size.y:
						object.queue_free()
						global.spawned_objects.erase(object)
					
			else:
				global.spawned_objects.erase(object)
				
	
func barrier_deletion():
	#check if barriers no longer exist 
	for barrier in global.current_barriers:
		if not is_instance_valid(barrier):
			global.current_barriers.erase(barrier)
	for barrier in global.left_barriers:
		if not is_instance_valid(barrier):
			global.left_barriers.erase(barrier)
		if barrier not in global.current_barriers and not is_instance_valid(barrier):
			global.left_barriers.erase(barrier)
		if barrier not in global.current_barriers and is_instance_valid(barrier):
			barrier.queue_free()
			global.left_barriers.erase(barrier)
	for barrier in global.right_barriers:
		if not is_instance_valid(barrier):
			global.right_barriers.erase(barrier)
		if barrier not in global.current_barriers and not is_instance_valid(barrier):
			global.right_barriers.erase(barrier)
		if barrier not in global.current_barriers and is_instance_valid(barrier):
			barrier.queue_free()
			global.right_barriers.erase(barrier)
			
	# check current barriers size
	if global.current_barriers.size() > 8 :
		if is_instance_valid(global.current_barriers[8]):
			global.current_barriers[8].queue_free()
			global.current_barriers.erase(global.current_barriers[8])
		else:
			global.current_barriers.erase(global.current_barriers[8])
		
	for barrier in global.current_barriers:
		if is_instance_valid(barrier):
			if barrier.position.y <=  0 - barrier.get_node("CollisionShape2D").shape.size.y * 3  or barrier.position.y >= 700 +  barrier.get_node("CollisionShape2D").shape.size.y:
				if barrier in global.left_barriers:
					global.left_barriers.erase(barrier)
				else:
					global.right_barriers.erase(barrier)
				if barrier in global.current_barriers:
					var target_barrier = barrier
					barrier.queue_free()
					global.current_barriers.erase(target_barrier)
		else:
			
			global.current_barriers.erase(barrier)

			
			
	for barrier in global.current_barriers:
		if is_instance_valid(barrier):
			if barrier.global_position.y < $left_barrier_spawner.global_position.y - screen_size.y - barrier.get_node("CollisionShape2D").shape.size.y/2:
				if barrier in global.left_barriers:
					global.left_barriers.erase(barrier)
				else:
					global.right_barriers.erase(barrier)
				if barrier in global.current_barriers:
					var target_barrier = barrier
					barrier.queue_free()
					global.current_barriers.erase(target_barrier)
		else:
			global.current_barriers.erase(barrier)

		
func select_barrier_deletion(selected_barrier):
	for barrier in global.current_barriers:
		if barrier == selected_barrier:
			if barrier in global.left_barriers:
				global.left_barriers.erase(barrier)
			else:
				global.right_barriers.erase(barrier)
			if barrier in global.current_barriers:
				var target_barrier = barrier
				barrier.queue_free()
				global.current_barriers.erase(target_barrier)
	
func update_score(difficulty):
	if can_update:
		var score_update_rate = Timer.new()
		score_update_rate.one_shot = true
		score_update_rate.wait_time = floor(difficulty/2)
		score_update_rate.timeout.connect(update_score_timeout)
		add_child(score_update_rate)
		score_update_rate.start()
		can_update = false
func update_score_timeout():
	
	global.score += 1
	if global.score > global.high_score:
		global.high_score = global.score
	else:
		global.high_score = global.high_score
	can_update = true
		
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "start_game":
		$Node2D/facility_door.queue_free()
		global.start_motion = true
		create = true
		create_objects()
		
func door_timeout():
	$Node2D/facility_door.play("open")
	

func _on_player_attack_button_pressed() -> void:
	global.player_attack = true

func _on_barrier_border_body_entered(body: Node2D) -> void:
	pass
	#if body in global.current_barriers:
	#	if body in global.left_barriers:
	#		global.left_barriers.erase(body)
	#	if body in global.right_barriers:
	#		global.right_barriers.erase(body)
	#	global.current_barriers.erase(body)
	#if body in spawned_objects:
	#	spawned_objects.erase(body)
	#body.queue_free()


func _on_down_button_pressed() -> void:
	global.go_up = true


func _on_up_button_pressed() -> void:
	global.go_down


func _on_shift_button_pressed() -> void:
	global.shift_pressed = true


func _on_up_button_released() -> void:
	global.go_up = false


func _on_down_button_released() -> void:
	global.go_down = false


func _on_barrier_control_timer_timeout() -> void:
	if global.game_started:
		barrier_control()
		barrier_deletion()
		object_deletion()
		

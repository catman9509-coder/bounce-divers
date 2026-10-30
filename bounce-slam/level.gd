extends Node2D
# preloads
var movement_control : PackedScene = preload("res://direction_control.tscn")
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
var screen_size
var screen_y
var side_delayed : String
var initial_camera
var create = false
var difficulty = global.difficulty
var object_speed = 150
var game_start : bool

var add_left_count = true
var add_right_count = true
var can_spawn_barrier = true
var latest_right_barrier
var latest_left_barrier
var can_left_create = true
var can_right_create = true
var other_input = false
var barrier_limit = 8
var barrier_check_timer
var stop_barrier_creation = false
var exceeded_barrier_limit = false
var current_barrier_spawn_y
var rider_has_been_ejected = false
var initial_camera_pos : Vector2

# update_score
var can_update = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_camera_pos = $Camera2D.position
	await global.scene_change_transition()
	adjust_borders()
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
	create_barrier_check_timer()

	
	
	
	initial_camera = $Camera2D.position
	screen_size = get_viewport().get_visible_rect().size
	game_start = true
	await spawn_barriers(difficulty, $player.hori_direction, 2)
	


	object_spawn_point_1 = $obstacle_spawnpoint_1
	object_spawn_points.append(object_spawn_point_1)
	object_spawn_point_2 = $obstacle_spawnpoint_2
	object_spawn_points.append(object_spawn_point_2)
	object_spawn_point_3 = $obstacle_spawnpoint_3
	object_spawn_points.append(object_spawn_point_3)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global.current_barriers.size() > barrier_limit:
		print("current barriers !!!!!!!!!!!!!!!!!!!!!!!!!!!", global.current_barriers.size())
		exceeded_barrier_limit = true
		can_spawn_barrier = false
	if global.spawned_objects.size() > 8:
		print("current spawned object@!!!!!!!!!!!!!!!!!!!!!! ", global.spawned_objects.size())
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
		$ui.visible = false
		var vehicle_explosion = player_death_effect.instantiate()
		vehicle_explosion.position = $player.global_position
		vehicle_explosion.subject = "player"
		add_child(vehicle_explosion)
		var death_menu_timer = Timer.new()
		death_menu_timer.wait_time = 2.0
		death_menu_timer.autostart = false
		death_menu_timer.one_shot = true
		death_menu_timer.timeout.connect(reveal_death_menu)
		add_child(death_menu_timer)
		$death_menu.position.x + 100
		death_menu_timer.start()
		global.death = false
	if global.health > 0 and is_instance_valid($player) and $player.can_move == true:
		global.update_difficulty()
		update_score(difficulty)
	if $player.can_move == true:
		game_start = false
	else:
		game_start = true
	if game_start == false:
		global.game_started = true
		if global.current_barriers.size() > 7:
			can_spawn_barrier = false
		if global.current_barriers.size() < 2:
			can_spawn_barrier = true
	#print("------------------------------------current count: ", current_barriers.size())
	if rider_has_been_ejected:
		var adjusted_screen_size = screen_size * 1/$Camera2D.zoom
		var screen_center = $Camera2D.get_screen_center_position()
		var right_corner = Vector2(screen_center.x + adjusted_screen_size.x/2, screen_center.y - adjusted_screen_size.y/2)
		$Camera2D.position_smoothing_enabled
		$Camera2D.zoom = Vector2(3, 3)
		$Camera2D.position.x = $ejected_rider.position.x
		$Camera2D.position.y = $ejected_rider.position.y
		$death_menu.position.x = right_corner.x
		$death_menu.position.y = right_corner.y
		$death_menu.scale.x = 1/$Camera2D.zoom.x
		$death_menu.scale.y = 1/$Camera2D.zoom.y
		

				

	
#lets the menu to restart or return to main_menu appear

func reveal_death_menu():
	if is_instance_valid($death_background):
		$death_menu.get_node("AnimationPlayer").play("appear")
		$death_background.get_node("AnimationPlayer").play("appear")
		$death_menu.visible = true
		$death_background.visible = true
# button held
func check_last_barrier(side):
	var should_create = false
	
	match side:
		"left":
			if is_instance_valid(global.left_barriers.back()):
				var last_left_barrier = global.left_barriers.back()
				var last_left_info = get_barrier_size(last_left_barrier)
				if last_left_info["low_point"] < current_barrier_spawn_y :
					should_create = true
				else:
					should_create = false
			else:
				if global.left_barriers.is_empty():
					should_create = true
					
		"right":
			if is_instance_valid(global.right_barriers.back()):
				var last_right_barrier = global.right_barriers.back()
				var last_right_info = get_barrier_size(last_right_barrier)
				if last_right_info["low_point"] < current_barrier_spawn_y :
					should_create = true
				else:
					should_create = false
			else:
				if global.right_barriers.is_empty():
					should_create = true
		
	return should_create
		
# left side spawns
func create_barrier(side : String):
	print("called")
	var spawned_barrier = false

	if spawned_barrier == false and check_last_barrier(side) == true:
		match side:
			"left":
				var barrier = barriers[randi() % barriers.size()].instantiate()
				barrier.can_create_enemy = false
				barrier.name = "barrier"
				add_child(barrier)
				#var barrier_size = get_barrier_size(barrier)
				global.current_barriers.append(barrier)
				global.left_barriers.append(barrier)
				if game_start:
					barrier.global_position.x = $left_barrier_spawner.global_position.x
					barrier.global_position.y = $player.global_position.y 
					current_barrier_spawn_y = $player.global_position.y 
				else:
					barrier.global_position.x = $left_barrier_spawner.global_position.x
					barrier.global_position.y = $left_barrier_spawner.global_position.y + barrier.get_node("CollisionShape2D").shape.size.y/2
					current_barrier_spawn_y = $left_barrier_spawner.global_position.y 
				
				if barrier in get_children():
					spawned_barrier = true
					print("barrier created using create")
				
			"right":
				var barrier = barriers[randi() % barriers.size()].instantiate()
				barrier.can_create_enemy = false
				barrier.name = "barrier"
				add_child(barrier)
				#var barrier_size = get_barrier_size(barrier)
				global.current_barriers.append(barrier)
				global.right_barriers.append(barrier)
				if game_start:
					barrier.global_position.x = $right_barrier_spawner.global_position.x
					barrier.global_position.y = $player.global_position.y 
					current_barrier_spawn_y = $player.global_position.y 
				else:
					barrier.global_position.x = $right_barrier_spawner.global_position.x
					barrier.global_position.y = $right_barrier_spawner.global_position.y + barrier.get_node("CollisionShape2D").shape.size.y/2
					current_barrier_spawn_y = $right_barrier_spawner.global_position.y 
	
					#if barrier_size["high_point"] < $borders/down_border.global_position.y:
					#		barrier.global_position.y += $borders/down_border.global_position.y - barrier_size["high_point"]
					#		print("barrier shifted")
				if barrier in get_children():
					spawned_barrier = true
					print("barrier created using create")
				else:
					can_spawn_barrier = false
			_:
				spawned_barrier = true
func spawn_barriers(difficulty, side, limit):

	stop_barrier_creation = false
	var spawned_barriers = 0
	var possible_sides = ["left", "right"]
	
	if can_spawn_barrier and spawned_barriers < limit and stop_barrier_creation == false:
		#side = possible_sides.pick_random()
		for num in range(0, limit):
				await create_barrier(side)
				if limit > 1:
					for option in possible_sides:
						if option == side:
							pass
						else:
							side = option
	#	if spawned_barriers < limit:
	#		if game_start:
	#			spawned_barriers = await create_barrier(side, spawned_barriers, 1)
	#			for sides in possible_sides:
	#				if sides != side:
	#					next_side = sides
	#			if limit > 1:
	#				spawned_barriers = await create_barrier(next_side, spawned_barriers, 1)
	#			
	#		else:
	#			var barrier = barriers[randi() % barriers.size()].instantiate()
	#			barrier.can_create_enemy = false
	#			barrier.name = "barrier"
	#			if spawned_barriers < limit:
	#				match side:
	#					"left":
	#						if global.left_barriers.size() == 0:
	#							spawned_barriers = await create_barrier(side, spawned_barriers, 1)
	#						else:
	#							if is_instance_valid(global.left_barriers.back()):
	#								if barrier.global_position.y >= global.left_barriers.back().global_position.y - global.left_barriers.back().get_node("CollisionShape2D").shape.size.y/2 and barrier.global_position.y <= global.left_barriers.back().global_position.y + global.left_barriers.back().get_node("CollisionShape2D").shape.size.y/2:
	#									pass
	#								else:
	#									spawned_barriers = await create_barrier(side, spawned_barriers, 1)
	#									
	#					"right":
	#						if global.right_barriers.size() == 0:
	#							spawned_barriers = await create_barrier(side, spawned_barriers, 1)
	#						else:
	#							if is_instance_valid(global.right_barriers.back()):
	#								if barrier.global_position.y >= global.right_barriers.back().global_position.y - global.right_barriers.back().get_node("CollisionShape2D").shape.size.y/2 and barrier.global_position.y <= global.right_barriers.back().global_position.y + global.right_barriers.back().get_node("CollisionShape2D").shape.size.y/2:
	#									pass
	#								else:
	#									spawned_barriers = await create_barrier(side, spawned_barriers, 1)
	else:
		print("unable to create new barrier")
	side_delayed = side
	delay(difficulty)

func count_spawned_objects():
	
	var object_count = 0
	for object in global.spawned_objects:
		object_count += 1
	if object_count > 2:
		print("current amount of spawned obejcts is --------------------- : ", object_count)
func barrier_control():
	var need_barrier = false
	var last_left_barrier 
	var last_right_barrier
	var viewport_size = get_viewport().get_visible_rect().size
	if not global.left_barriers.is_empty():
		if is_instance_valid(global.left_barriers.back()) :
			last_left_barrier = global.left_barriers.back()
			if last_left_barrier:
				if not last_left_barrier.global_position.y + last_left_barrier.get_node("CollisionShape2D").shape.size.y/2 >= viewport_size.y/2:
					need_barrier = true
	else:
		need_barrier = true
	if not global.right_barriers.is_empty():
		if is_instance_valid(global.right_barriers.back()):
			last_right_barrier = global.right_barriers.back()
			if last_right_barrier:
				if not last_right_barrier.global_position.y + last_right_barrier.get_node("CollisionShape2D").shape.size.y/2 >=  viewport_size.y/2:
					need_barrier = true
				else:
					need_barrier = false
	else:
		need_barrier = true
	if global.right_barriers.size() < 3 and need_barrier :

		await emergency_barrier_creation("right")

	#if global.right_barriers.is_empty() and need_barrier or global.right_barriers.size() == 0 and need_barrier:

	#	await emergency_barrier_creation("right")


	if global.left_barriers.size() < 3 and need_barrier :
		#can_spawn_barrier = true
		await emergency_barrier_creation("left")


	#if global.left_barriers.is_empty() and need_barrier or global.left_barriers.size() == 0 and need_barrier:
		#can_spawn_barrier = true
	#	emergency_barrier_creation("left")
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
	var delay_timer = Timer.new()
	if game_start:
		delay_timer.wait_time = 1
	if game_start == false:
		delay_timer.wait_time = 2 #difficulty/2
	can_spawn_barrier = false
	delay_timer.one_shot = true
	delay_timer.timeout.connect(delay_timeout)
	add_child(delay_timer)
	delay_timer.start()
func delay_timeout():
	var spawn_limit = 1#randi_range(1, 3)
	can_spawn_barrier = true
	match side_delayed:
		"left":
			await spawn_barriers(difficulty, "right", spawn_limit)

		"right":
			await spawn_barriers(difficulty, "left", spawn_limit)

			
		_:
			pass
	if game_start:
		game_start = false
func emergency_barrier_creation(side):
	
	var spawned_barriers = 0
	if spawned_barriers == 0 and game_start == false:
		spawned_barriers = await create_barrier(side)
	
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
				
func get_barrier_size(barrier):
	if is_instance_valid(barrier):
		var side
		if barrier in global.left_barriers:
			side = "left"
		if barrier in global.right_barriers:
			side = "right"
		var size = barrier.get_node("CollisionShape2D").shape.size
		var low_point = barrier.global_position.y + size.y/2
		var high_point = barrier.global_position.y - size.y/2
		var barrier_stats = {"size" : size, "low_point" : low_point, "high_point" : high_point, "side" : side}
		return barrier_stats
	else:
		var side
		if barrier in global.left_barriers:
			side = "left"
		if barrier in global.right_barriers:
			side = "right"
		return side
	
func barrier_deletion():
	print(global.current_barriers)
	print("left barriers", global.left_barriers)
	print("right barriers", global.right_barriers)
					
	# check current barriers size
	for barrier in global.current_barriers:
		if is_instance_valid(barrier):
			var barrier_stats = get_barrier_size(barrier)
			if barrier_stats["low_point"] < 0:
				erase_barrier(barrier, barrier_stats["side"])
				print("barrier deleted")
		else:
			var side = get_barrier_size(barrier)
			erase_barrier(barrier, side)
			print("removed barrier occupying memory")
	if exceeded_barrier_limit:
		for barrier in global.current_barriers:
			
			if barrier == global.current_barriers.back():
				var barrier_info = get_barrier_size(barrier)
				erase_barrier(barrier, barrier_info["side"])
			if global.current_barriers.size() <= barrier_limit:
				exceeded_barrier_limit = false
		
		
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


func barrier_check_timer_timeout()-> void:
	#barrier_control()
	barrier_deletion()
	object_deletion()
	barrier_check_timer.wait_time = 1
	barrier_check_timer.start()

	
func adjust_borders():
	$borders/up_border.position.y = global.screen_pos.y
	$borders/down_border.position.y = 640
func erase_barrier(barrier, side):
	match side:
		"left":
			global.left_barriers.erase(barrier)
			global.current_barriers.erase(barrier)
			
		"right":
			global.right_barriers.erase(barrier)
			global.current_barriers.erase(barrier)
	if is_instance_valid(barrier):
		barrier.queue_free()
	stop_barrier_creation = true
func create_barrier_check_timer():
	barrier_check_timer = Timer.new()
	barrier_check_timer.wait_time = 1
	barrier_check_timer.autostart = false
	barrier_check_timer.one_shot = false
	barrier_check_timer.timeout.connect(barrier_check_timer_timeout)
	add_child(barrier_check_timer)
	barrier_check_timer.start()
	

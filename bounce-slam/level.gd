extends Node2D
var ejected_rider : PackedScene = load("res://ejected_rider.tscn")
var main_scroll_speed = 50
var background_sprites = []
var background_start_pos
var bg_height 
var	object_spawn_point_1 
var	object_spawn_point_2  
var	object_spawn_point_3  
var upgrade_crate : PackedScene = load("res://upgrade_crate.tscn")
var base_upgrade_crate : PackedScene = load("res://base_upgrade_crate.tscn")
var trash : PackedScene = load("res://trash.tscn")
var enemy_1 : PackedScene = load("res://enemy_1.tscn")
var enemy_2 : PackedScene = load("res://enemy_2.tscn")
var enemy_3 : PackedScene = load("res://enemy_3.tscn")
var enemy_4 : PackedScene = load("res://enemy_4.tscn")
var hori_shift_fuel : PackedScene = load("res://hori_shift_fuel.tscn")
var object_spawn_points = []
var possible_objects = [enemy_1, enemy_2, enemy_3, enemy_4, upgrade_crate, base_upgrade_crate, trash, hori_shift_fuel]
var spawned_objects = []
var barrier_1 : PackedScene = load("res://barrier_1.tscn")
var barrier_2 : PackedScene = load("res://barrier_2.tscn")
var barrier_3 : PackedScene = load("res://barrier_3.tscn")
var barrier_4 : PackedScene = load("res://barrier_4.tscn")
var none : PackedScene = load("res://barrier_1.tscn")
var barriers = [barrier_1, barrier_2, barrier_3, barrier_4]
var barrier_heights = [636.0,411.0, 230.0, 96.0]
var left_barriers = []
var right_barriers = []
var left_create : bool
var right_create : bool
var barrier_space = 400
var last_left_difference=0
var last_right_difference = 0
var initial_vert_control_position
var vert_control_hold = false
var vert_direction : String
var player_vert_speed = 10 
var object_speed = 5
var screen_size
var screen_y
var side_delayed : String
var initial_camera
var create = false
var difficulty = global.difficulty
var barrier_speed = 400 / difficulty

# update_score
var can_update = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global.stored_coins = 1000
	global.score = 0
	global.gathered_coins = 0
	last_left_difference = 0
	last_right_difference = 0
	
	background_sprites = [$background/main_bg]
	bg_height = $background/main_bg.texture.get_height()
	background_start_pos = $background/main_bg.position.y
	
	
#	$ParallaxBackground. = Vector2(0,-50)
	var door_timer = Timer.new()
	door_timer.wait_time = 0.39
	door_timer.one_shot = true
	door_timer.timeout.connect(door_timeout)	
	add_child(door_timer)
	door_timer.start()
	$player.modulate = 0
	$AnimationPlayer.play("start_game")
	global.immunity_time(3.0)
	
	initial_camera = $Camera2D.position
	screen_size = get_viewport().get_visible_rect().size
	
	left_create = bool(randi() % 2)
	right_create = not left_create
	if left_create == true:
		$player.hori_direction = "left"
	else:
		$player.hori_direction = "right"
	
	initial_vert_control_position = $player_vert_control.position
	object_spawn_point_1 = $obstacle_spawnpoint_1
	object_spawn_points.append(object_spawn_point_1)
	object_spawn_point_2 = $obstacle_spawnpoint_2
	object_spawn_points.append(object_spawn_point_2)
	object_spawn_point_3 = $obstacle_spawnpoint_3
	object_spawn_points.append(object_spawn_point_3)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global.death:
		var rider = ejected_rider.instantiate()
		rider.position = $player.position
		add_child(rider)
		global.death = false
	global.update_difficulty()
			
				
				
	if $player.can_horizontal_shift == true:
		$ui/emergency_shift.visible = true
	else:
		$ui/emergency_shift.visible = false
	if global.health > 0 and $player.can_move == true:
		update_score(difficulty)
	object_deletion()
	barrier_deletion()
	for sprite in background_sprites:
		sprite.position.y -= main_scroll_speed * delta
		if sprite.position.y <= bg_height:
			sprite.position.y += bg_height
#	$ParallaxBackground.scroll_offset += speed * delta
	for object in spawned_objects:
		if is_instance_valid(object):
			if "enemy" not in object.name:
				object.position.y -= object_speed
				if object.has_method("magnetic"):
					if object.fire == true:
						object.position.y -=0
					
			else:
				if object.special_action == false:
					object.position.y -= object_speed
				else:
					object.velocity = Vector2.ZERO
		else:
			spawned_objects.erase(object)
				
	for barrier in left_barriers:
		barrier.position.y -= barrier_speed * delta
	for barrier in right_barriers:
		barrier.position.y -= barrier_speed * delta
	if left_create:
		left_barrier_spawn(difficulty)
		left_create = false
		
	if right_create:
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
	if left_barriers.size() < 4:
		var left_barrier = barriers[randi() % barriers.size()].instantiate()
		left_barrier.name = "left_barrier"
		left_barriers.append(left_barrier)
		add_child(left_barrier)
		var left_height = left_barrier.get_node("CollisionShape2D").shape.size.y
		var offset = 0
		if last_left_difference == 0:
			offset = -($left_barrier_spawner.position.y - $player.position.y)/2
		else:
			if left_barriers[0].position.y <= $left_barrier_spawner.position.y-200 and left_barriers[0].position.y >= $left_barrier_spawner.position.y -400:
				offset = ($left_barrier_spawner.position.y - left_barriers[0].position.y)
			else:
				if left_height >= last_left_difference:
					offset = left_height
				else:	
					offset = -left_height/3
				
			print(($left_barrier_spawner.position.y - left_barriers[0].position.y) + (left_height))
			
		left_barrier.position.x = $left_barrier_spawner.position.x
		left_barrier.position.y = $left_barrier_spawner.position.y + offset#+ ($left_barrier_spawner.position.y - left_barriers[0].position.y) #- offset + ($left_barrier_spawner.position.y - left_barriers[0].position.y) #offset 
		last_left_difference = left_height
		side_delayed = "left"
		delay(difficulty)
		print("left")
		left_create = false
	else:
		side_delayed = "left"
		delay(difficulty)

func left_timer_timeout():
	left_create = true
# right side spawns
func right_barrier_spawn(difficulty):
	if right_barriers.size() < 4:
		var right_barrier = barriers[randi() % barriers.size()].instantiate()
		print(right_barrier)
		right_barrier.name = "right_barrier"
		right_barrier.get_node("AnimatedSprite2D").flip_h = true
		right_barriers.append(right_barrier)
		add_child(right_barrier)
		var offset = 0
		var right_height = right_barrier.get_node("CollisionShape2D").shape.size.y
		if last_right_difference == 0:
			offset = -($right_barrier_spawner.position.y - $player.position.y)/2
		else:
			if right_barriers[0].position.y <= $right_barrier_spawner.position.y-200 and right_barriers[0].position.y >= $right_barrier_spawner.position.y -400:
					offset = ($right_barrier_spawner.position.y - right_barriers[0].position.y)
			else:
				if right_height >= last_right_difference:
					offset = right_height
				else:
					offset = right_height/3
				

				
		right_barrier.position.x = $right_barrier_spawner.position.x
		right_barrier.position.y = $right_barrier_spawner.position.y + offset #+ ($right_barrier_spawner.position.y - right_barriers[0].position.y)# - offset + ($right_barrier_spawner.position.y - right_barriers[0].position.y)
		last_right_difference = right_height
		side_delayed = "right"
		delay(difficulty)
		print("right")
		right_create = false
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
	if create:
		var object = possible_objects[randi() % possible_objects.size()].instantiate()
		var spawn_point = object_spawn_points.pick_random()
		object.position = spawn_point.position

		spawned_objects.append(object)
		add_child(object)
		print("crate created")
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
func object_deletion():
	
	for body in $enemy_border.get_overlapping_bodies():
		if "enemy" in body.name and body in spawned_objects:
			spawned_objects.erase(body)
		body.queue_free()
func barrier_deletion():
	for barrier in left_barriers:
		if barrier.position.y < $left_barrier_spawner.position.y - screen_size.y - barrier.get_node("CollisionShape2D").shape.size.y*3:
			barrier.queue_free()
			left_barriers.erase(barrier)
			print("barrier deleted")
	for barrier in right_barriers:
		if barrier.position.y < $right_barrier_spawner.position.y - screen_size.y - barrier.get_node("CollisionShape2D").shape.size.y*3:
			barrier.queue_free()
			right_barriers.erase(barrier)
			print("barrier deleted")
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

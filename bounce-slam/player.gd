extends CharacterBody2D
#screen variables
var ejected_rider : PackedScene = load("res://ejected_rider.tscn")
var death_menu : PackedScene = load("res://death_menu.tscn")
var death_background : PackedScene = load("res://death_background.tscn")
var create_screen = false

#
var base_attack : PackedScene = preload("res://player_attack.tscn")
var projectile_attack : PackedScene = preload("res://player_projectile.tscn")
var possible_directions = ["left", "right"]
var held_projectiles = []
const left_speed = -100.0
const right_speed = 100.0
var possible_speeds = [left_speed, right_speed]
const JUMP_VELOCITY = -400.0
var start_motion = false
var hori_direction
var health
var can_move = true
var speed_limit = 190
var motion_attack = false
var can_horizontal_shift = true
var shift_fuel_count = 1
var vertical_direction = " "
var current_collision_count = 0
var rider_has_been_ejected = false


# interaction variables
var cleaned
# take track of speed
var last_speed = 0
# player states
#player attack
var can_attack = true
#var attacking = false

func _ready():
	can_move = false
	change_player()
	global.state = global.states[0]
	hori_direction = possible_directions[randi() % possible_directions.size()]
	
func player():
	pass
func _physics_process(delta: float) -> void:
				
	for upgrades in global.owned_purchaseable_upgrades:
		if upgrades == "extra life":
			global.extra_life = true
	
	health = global.health
	#death
	if global.player_attacked:
		$AnimationPlayer.play("attacked")
	if health <= 0:
		if global.extra_life == true:
			global.immunity_time(2.0)
			revival()
			var index = global.owned_purchaseable_upgrades.find("extra life")
			global.owned_purchaseable_upgrades.pop_at(index)
			global.health = 2
			global.purchaseable_upgrades[0]["owned"] = false
			global.extra_life = false
		else:
			self.visible = false
			if global.death_screen:
				if create_screen:
					
					create_screen = false
					death_screen()

			else:
				get_tree().reload_current_scene()
				global.start_game = false
				global.health = 2
	else:
		create_screen = true
# start motion to begin game
	if global.start_motion:
		can_move = true
		global.start_motion = false
	directional_speed(hori_direction)

	global.shift = can_horizontal_shift
	global.shift_fuel_count = shift_fuel_count
	if global.start_game == false:
			global.start_game = true
			if can_attack:
				player_attack(global.state)
			can_attack = false
			global.player_attack = false
		
	if can_move:
		
		if Input.is_action_pressed("ui_down") or global.go_down:
			$Node2D/body.play(global.current_vehicle_skin + " forward")
			vertical_direction = "forward"
			if velocity.y < speed_limit:
				velocity.y += 5
		if Input.is_action_pressed("ui_up") or global.go_up:
			$Node2D/body.play(global.current_vehicle_skin + " back")
			vertical_direction = "back"
			if velocity.y > -(speed_limit):
				velocity.y -= 5
			

		if Input.is_action_just_pressed("ui_left") or global.player_attack:
			if can_attack:
				player_attack(global.state)
			can_attack = false
			global.player_attack = false
		if Input.is_action_pressed("ui_right") or global.shift_pressed:
			hori_shift()
			global.shift_pressed = false

			
			
			#if velocity.y > 0:
			#	velocity.y -= 50
	# detects the position of coming enemie's y positions
	
	for body in $horizontal_detector.get_overlapping_bodies():
		if body.position.y > position.y:
			
			global.enemy_down = true
			global.enemy_up = false
		if body.position.y < position.y:
			global.enemy_up = true
			global.enemy_down = false
		else:
			global.enemy_up = false
			global.enemy_down = false
	#change_player()
	if global.normalize == true:
		if velocity.y > 0:
			velocity.y -= 10
		if velocity.y < 0:
			velocity.y += 10
		if velocity.y == 0:
			motion_attack = false
			global.normalize = false
			change_player()
				
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	move_and_slide()
	var collision = move_and_collide(velocity * delta)
	for body in $bumper_detection_area.get_overlapping_bodies():
		if body.position.x < position.x:
			$Node2D/bumpers.play(global.current_vehicle_skin + " left")
		if body.position.x > position.x:
			$Node2D/bumpers.play(global.current_vehicle_skin + " right")
	for body in $detection_area.get_overlapping_bodies():
		if body.name.contains("fuel"):
			shift_fuel_count += 1
			if get_tree().current_scene.name == "level":
				var current_scene = get_tree().current_scene
				current_scene.get_node("ui").should_play_ready = true
				
		if body.position.x < position.x:
			velocity.x = right_speed
			hori_direction = "right"
		if body.position.x > position.x:
			velocity.x = left_speed
			hori_direction = "left"
		
				
func hori_shift():
	var shift_timer = Timer.new()
	shift_timer.one_shot = true
	shift_timer.wait_time = 1.0
	shift_timer.timeout.connect(shift_timer_timeout)
	add_child(shift_timer)
	if shift_fuel_count > 0:
		match hori_direction:
			"right":
				if can_horizontal_shift:
					hori_direction = "left"
				can_horizontal_shift = false
			"left":
				if can_horizontal_shift:
					hori_direction = "right"
				can_horizontal_shift = false
			_:
				can_horizontal_shift = false
	shift_timer.start()
func shift_timer_timeout():
	if can_horizontal_shift == false and shift_fuel_count > 0:
		shift_fuel_count -= 1
		can_horizontal_shift = true
	if shift_fuel_count < 1:
		can_horizontal_shift = false
		
				
		
func directional_speed(direction):
	if direction == "right":
		velocity.x = right_speed
		last_speed = right_speed
	if direction == "left":
		velocity.x = left_speed
		last_speed = left_speed
	else:
		if velocity.x == 0 and global.start_game == true:
			velocity.x = last_speed
func player_attack(current_state):
	match current_state:
		"base":
			global.immunity_time(1.0)
			var attack = base_attack.instantiate()
			$Node2D/bumpers.play(global.current_vehicle_skin + " attack")
			attack.get_node("Node2D/AnimatedSprite2D2").play("attack")
			attack.get_node("AnimationPlayer").play("base_attack")
			attack.position = $player_center.position
			add_child(attack)
			
		"rocket_burst_upgrade":
			motion_attack = true
			global.immunity_time(2.0)
			var flash = death_background.instantiate()
			flash.get_node("AnimationPlayer").play("rocket_burst")
			get_parent().add_child(flash)
			velocity.y = 400
			var attack = base_attack.instantiate()
			attack.get_node("Node2D/AnimatedSprite2D").play("rocket_burst")
			attack.get_node("AnimationPlayer").play("rocket_burst")
			attack.position = $player_center.position
			add_child(attack)		
		"magnet":
			if held_projectiles.is_empty() == false:
				if is_instance_valid(held_projectiles[0]):
					held_projectiles[0].fire = true
					held_projectiles.pop_front()
					print(held_projectiles)
			if held_projectiles == []:
				global.immunity_time(1.0)
				var attack = base_attack.instantiate()
				$Node2D/bumpers.play(global.current_vehicle_skin + " attack")
				attack.get_node("Node2D/AnimatedSprite2D2").play("attack")
				attack.get_node("AnimationPlayer").play("base_attack")
				attack.position = $player_center.position
				add_child(attack)
		"soap_bar_upgrade":
			var attack = projectile_attack.instantiate()
			attack.mode = "soap_bar"
			attack.global_position = $player_center.global_position
			get_parent().add_child(attack)
		"soap_bomb_upgrade":
			var attack = projectile_attack.instantiate()
			attack.mode = "soap_bomb"
			attack.global_position = $player_center.global_position
			get_parent().add_child(attack)
		"immunity_upgrade":
			var attack = base_attack.instantiate()
			attack.get_node("Node2D/AnimatedSprite2D2").play("attack")
			attack.get_node("AnimationPlayer").play("base_attack")
			add_child(attack)
			attack.position = $player_center.position
		
			
					
		_:
			pass
	var attack_cooldown = Timer.new()
	attack_cooldown.wait_time = 2.0
	attack_cooldown.one_shot = true
	attack_cooldown.timeout.connect(attack_cooldown_timeout)
	add_child(attack_cooldown)
	attack_cooldown.start()
func attack_cooldown_timeout():
	can_attack = true
func clean_barriers():
	for body in $detection_area.get_overlapping_bodies():
		if "barrier" in body.name:
			pass
			#body.get_node("AnimatedSprite2D").play("clean")
func death_screen():
	global.death = true
	save_manager.save()
	if rider_has_been_ejected == false:
		var ejection_bubble = ejected_rider.instantiate()
		ejection_bubble.position = self.position
		get_parent().add_child(ejection_bubble)
	rider_has_been_ejected = true
	if get_tree().current_scene.name == "level":
		var current_scene = get_tree().current_scene
		current_scene.rider_has_been_ejected = true
	var death_background = death_background.instantiate()
	get_parent().add_child(death_background)
	death_background.get_node("AnimationPlayer").play("appear")
	death_background.visible = false
	var death_screen = death_menu.instantiate()
	death_screen.get_node("ColorRect/MarginContainer/VBoxContainer/resume").visible = false
	death_screen.get_node("score").text = "distance: " + str(global.score) +" parsecs"
	death_screen.position = Vector2(get_viewport_rect().size.x/2, get_viewport_rect().size.y/2)
	get_parent().add_child(death_screen)
	death_screen.get_node("AnimationPlayer").play("appear")
	death_screen.visible = false

func revival():
	position = Vector2(get_viewport_rect().size.x/2, get_viewport_rect().size.y/2)
	var death_background = death_background.instantiate()
	get_parent().add_child(death_background)
	death_background.get_node("AnimationPlayer").play("rocket_burst")
	
func change_player():
	match global.state:
		"base":
			$Node2D/body.play(global.current_vehicle_skin + " default")
			$Node2D/bumpers.play(global.current_vehicle_skin + " default")
			$upgrade_effect.visible = false
		"immunity_upgrade":
			$upgrade_effect.visible = true
			$upgrade_effect.play("invincible")
			
		_:
			$upgrade_effect.visible = false
			
	if velocity.y > 0 and motion_attack == true:
		velocity.y -= 0.5
	if velocity.y < 0:
		velocity.y += 0.5
	if velocity.y <= 2 and velocity.y >= -2:
		velocity.y = 0

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attacked":
		$Node2D/body.play(global.current_vehicle_skin + " default")
		$Node2D/bumpers.play(global.current_vehicle_skin + " default")
		global.player_attacked = false
		global.game_started = true
func _on_horizontal_detector_body_entered(body: Node2D) -> void:
	if body.has_method("magnetic"):
		if global.state == "magnet":
			held_projectiles.append(body)
func _on_bumper_detection_area_body_entered(body: Node2D) -> void:
	if can_move:
		global.in_game_collisions += 1
		if $message_timer.wait_time < 0.2:
			$message_timer.wait_time += 0.1
		current_collision_count = global.in_game_collisions
		$message_timer.start()
func _on_message_timer_timeout() -> void:
	global.in_game_collisions = 0
	

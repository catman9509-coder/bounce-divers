extends Node2D
var title_screen : PackedScene =preload("res://title_screen.tscn")
var transition_effect : PackedScene = preload("res://transition_sprites.tscn")
var window_opened = ""
var open_profile_window = false
var profile_window_opened = false
var window_shown = false
var strg_window : PackedScene = preload("res://owned_items.tscn")
var shop_window : PackedScene = preload("res://shop.tscn")
var incoming_scene : String
var camera_speed = 20
var initial_camera_position : Vector2
var camera_hori_direction = ""
var camera_vert_direction = ""
var vert_move : bool
var hori_move : bool
var trueorfalse = [false, true]


# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	vert_move = trueorfalse.pick_random()
	hori_move = not vert_move
	initial_camera_position = $Camera2D.global_position
	camera_movement_control()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	control_button_animations()
	reveal_window()
	check_stats()
	idle_camera_shake($Camera2D, delta)

func _on_play_button_up() -> void:
	$Camera2D/button_console/play_button_sprite.play("released")
	window_opened = "none"

func _on_play_button_down() -> void:
	$Camera2D/button_console/play_button_sprite.play("pressed")
	global.transition_animation("res://level.tscn")



func _on_owned_items_button_down() -> void:
	$Camera2D/button_console/strg_button_sprite.play("pressed")
	if window_opened != "strg":
		window_opened = "strg"
		if is_instance_valid($shop):
			$shop.queue_free()
	else:
		if is_instance_valid($owned_items):
			$owned_items.queue_free()
		window_opened = "none"


func _on_owned_items_button_up() -> void:
	$Camera2D/button_console/strg_button_sprite.play("released")



func _on_shop_button_down() -> void:
	$Camera2D/button_console/shop_button_sprite.play("pressed")
	if window_opened != "shop":
		if is_instance_valid($owned_items):
			$owned_items.queue_free()
		window_opened = "shop"
	else:
		if is_instance_valid($shop):
			$shop.queue_free()
		window_opened = "none"


func _on_shop_button_up() -> void:
	$Camera2D/button_console/shop_button_sprite.play("released")
func control_button_animations():
	if window_opened == "none":
		for sprite in $Camera2D/button_console.get_children():
				sprite.play("normal")
	match window_opened:
		"strg":
			for sprite in $Camera2D/button_console.get_children():
				if sprite.name.contains("strg") == false:
					sprite.play("normal")
			
		"shop":
			for sprite in $Camera2D/button_console.get_children():
				if sprite.name.contains("shop") == false:
					sprite.play("normal")
		"none":
			for sprite in $Camera2D/button_console.get_children():
				if sprite.name.contains("play") == false:
					sprite.play("normal")
	if open_profile_window == false and profile_window_opened == false:
		$Camera2D/button_console/profile_window_sprite.play("closed")
	if open_profile_window:
		if profile_window_opened == false:
			$Camera2D/button_console/profile_window_sprite.play("open")
	else:
		if profile_window_opened == true:
			$Camera2D/button_console/profile_window_sprite.play("close")				
func reveal_window():
	if window_opened != " " or  "":
		match window_opened:
			"shop":
				if window_shown == false:
					var shop = shop_window.instantiate()
					shop.get_node("Control").position = $screen_point.position
					shop.get_node("Control").position.y -= 30 # offset
					shop.visible = false
					add_child(shop)
					
					$Camera2D/button_console/main_window_sprite.play("show")
					
				window_shown = true
			"strg":
				if window_shown == false:
					var owned_items = strg_window.instantiate()
					owned_items.get_node("Control").position = $screen_point.position 
					owned_items.visible = false
					add_child(owned_items)
					$Camera2D/button_console/main_window_sprite.play("show")
				window_shown = true
			"none":
				if window_shown == true:
					$Camera2D/button_console/main_window_sprite.play("hide")
					window_shown = false
				
			_:
				$Camera2D/button_console/main_window_sprite.play("hidden")
	pass

				
	


func _on_main_window_sprite_animation_finished() -> void:
	if $Camera2D/button_console/main_window_sprite.animation == "hide":
		$Camera2D/button_console/main_window_sprite.play("hidden")
		if is_instance_valid($shop):
			$shop.queue_free()
		if is_instance_valid($owned_items):
			$owned_items.queue_free()
	if $Camera2D/button_console/main_window_sprite.animation == "show":
		if is_instance_valid($shop):
			$shop.visible = true
		if is_instance_valid($owned_items):
			$owned_items.visible = true
		if is_instance_valid($shop) and window_opened != "shop":
			$shop.queue_free()
		if is_instance_valid($owned_items) and window_opened != "strg":
			$owned_items.queue_free()
		$Camera2D/button_console/main_window_sprite.pause()


func _on_profile_button_up() -> void:
	$Camera2D/button_console/profile_button_sprite.play("released")
	if open_profile_window:
		open_profile_window = false
		$Camera2D/CanvasLayer/Control3.visible = false
		$Camera2D/button_console/profile_button_sprite.play("normal")
		
	else:
		open_profile_window = true
		
func _on_profile_button_down() -> void:
	$Camera2D/button_console/profile_button_sprite.play("pressed")




func _on_profile_window_sprite_animation_finished() -> void:
	if $Camera2D/button_console/profile_window_sprite.animation == "close":
		profile_window_opened = false
	if $Camera2D/button_console/profile_window_sprite.animation == "open":
		profile_window_opened = true
		$Camera2D/CanvasLayer/Control3.visible = true
		$Camera2D/button_console/profile_window_sprite.pause()
			
func check_stats():
	$Camera2D/CanvasLayer/Control3/current_credit_balance/Label.text = str(global.stored_coins)
	$Camera2D/CanvasLayer/Control3/longest_distance/Label.text = str(global.high_score)
	$Camera2D/CanvasLayer/username.text = global.user_name

func transition():
	var new_scene_timer = Timer.new()
	new_scene_timer.wait_time = 1.0
	new_scene_timer.one_shot = true
	new_scene_timer.timeout.connect(new_scene_timer_timeout)
	add_child(new_scene_timer)
	var transition = transition_effect.instantiate()
	transition.get_node("AnimationPlayer").play("normal_transition")
	add_child(transition)
	new_scene_timer.start()
func new_scene_timer_timeout():
	get_tree().change_scene_to_file(incoming_scene)
func _on_settings_button_pressed() -> void:
	global.transition_animation("res://settings.tscn")
func idle_camera_shake(camera, delta):
	var possible_hori_directions = ["right", "left"]
	var possible_vert_directions = ["up", "down"]
	if camera_hori_direction == "":
		camera_hori_direction = possible_hori_directions.pick_random()
	if camera_vert_direction == "":
		camera_vert_direction = possible_vert_directions.pick_random()
	if camera.position.x <= initial_camera_position.x + 10 and camera.position.x >= initial_camera_position.x - 10 and hori_move:
		if camera_hori_direction == "right":
			camera.global_position.x += 0.2 
			if camera.position.x >= initial_camera_position.x + 10:
				camera_hori_direction = "left"		
				#hori_move = false	
		if camera_hori_direction == "left":
			camera.global_position.x -= 0.2
			if camera.position.x <= initial_camera_position.x - 10:
				camera_hori_direction = "right"	
				#hori_move = false		
	if camera.position.y <= initial_camera_position.y + 10 and camera.position.y >= initial_camera_position.y - 10 and vert_move:
		if camera_vert_direction == "up":
			camera.global_position.y -= 0.2
			if camera.position.y <= initial_camera_position.y - 10:
				camera_vert_direction = "down"		
				#vert_move = false
		if camera_vert_direction == "down":
			camera.global_position.y += 0.2
			if camera.position.y >= initial_camera_position.y + 10:
				camera_vert_direction = "up"
				#vert_move = false
				
func camera_movement_control():
	var camera_movement_timer = Timer.new()
	camera_movement_timer.autostart = false
	camera_movement_timer.wait_time = randi_range(1, 4)
	camera_movement_timer.one_shot = true 
	camera_movement_timer.timeout.connect(camera_movement_timer_timeout)
	add_child(camera_movement_timer)
	camera_movement_timer.start()
func camera_movement_timer_timeout():
	vert_move = trueorfalse.pick_random()
	hori_move = trueorfalse.pick_random()
	camera_movement_control()
	
	
	
	

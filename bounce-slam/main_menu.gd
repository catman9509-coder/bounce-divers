extends Node2D
var title_screen : PackedScene =preload("res://title_screen.tscn")
var suggest_ad_popup : PackedScene = preload("res://suggest_ad_popup.tscn")
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
var rider_name : StringName
var ad_suggestion_closed = false
var watching_rewarded_interstitial_ad = false
var rewarded_ad_watched = false
var console_button_pressed = false
var camera_stop = false
var camera_focused = false
var window_size = DisplayServer.window_get_size()
var selected_item = {"name": "", "category": "", "owned": null, "price": null, "description" : ""}
var vehicle_size : Vector2
var main_window_appeared = false
var hidden_elements



# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	GodotPlayGameServices.initialize()
func _ready() -> void:
	await global.scene_change_transition()
	setup()
	hidden_elements = [$Camera2D/CanvasLayer, $Camera2D/button_console]
	reveal_elements()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		
	control_button_animations()
	check_stats()
	if camera_stop == false:
		idle_camera_shake($Camera2D, delta)
	if ad_suggestion_closed == false:
		$suggest_ad_popup.popup()
	else:
		$suggest_ad_popup.hide()
	if watching_rewarded_interstitial_ad == true:
		$admob.load_rewarded_interstitial()
		watching_rewarded_interstitial_ad = false
	if window_opened == "" or window_opened == "none":
		$Camera2D.position = initial_camera_position

			
		
	

func _on_play_button_up() -> void:
	$Camera2D/button_console/play_button_sprite.play("released")
	window_opened = "none"
	

func _on_play_button_down() -> void:
	$shop.visible = false
	$owned_items.visible = false
	camera_stop = true
	$Camera2D.position = initial_camera_position
	$Camera2D/button_console/play_button_sprite.play("pressed")
	global.transition_animation("res://level.tscn")

func _on_owned_items_button_down() -> void:
	$Camera2D/button_console/strg_button_sprite.play("pressed")
	if console_button_pressed == false:
		if window_opened == "strg":
			window_opened = "none"
			console_button_pressed = true
		else:
			window_opened = "strg"
			console_button_pressed = true

func _on_owned_items_button_up() -> void:
	$Camera2D/button_console/strg_button_sprite.play("released")
	reveal_window()
	$shop.visible = false
	if $main_window.paused:
		$owned_items.visible = true
	if window_opened == "none":
		$owned_items.visible = false
		$main_window.hide_content()

	console_button_pressed = false
func _on_shop_button_down() -> void:

	$Camera2D/button_console/shop_button_sprite.play("pressed")
	if console_button_pressed == false:
		if window_opened == "shop":
			window_opened = "none"
			console_button_pressed = true
		else:
			window_opened = "shop"
			console_button_pressed = true
	print(window_opened)

func _on_shop_button_up() -> void:
	$Camera2D/button_console/shop_button_sprite.play("released")
	reveal_window()
	$owned_items.visible = false
	if $main_window.paused:
		$shop.visible = true
	if window_opened == "none":
		$shop.visible = false
		$main_window.hide_content()
		

	console_button_pressed = false
func control_button_animations():
	if window_opened == "none":
		for sprite in $Camera2D/button_console.get_children():
			if sprite.name.contains("normal"):
				sprite.play("normal")
	match window_opened:
		"strg":
			for sprite in $Camera2D/button_console.get_children():
				if sprite.name.contains("strg") == false and sprite.name.contains("_button_sprite"):
					sprite.play("normal")
			
		"shop":
			for sprite in $Camera2D/button_console.get_children():
				if sprite.name.contains("shop") == false and sprite.name.contains("_button_sprite"):
					sprite.play("normal")
		"none":
			for sprite in $Camera2D/button_console.get_children():
				if sprite.name.contains("play") == false and sprite.name.contains("_button_sprite"):
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
	if window_opened == "none":
		$Camera2D.position = initial_camera_position
		camera_stop = false
		$main_window.play_animation("disappear")
		$Camera2D/button_console.visible = true
		$Camera2D/CanvasLayer/Control2.visible = true
		$Camera2D/CanvasLayer/Control3.visible = false
		main_window_appeared = false
		
	else:
		$main_window.position = global.screen_pos
		$Camera2D.position = initial_camera_position
		$Camera2D/CanvasLayer/Control3.visible = false
		camera_stop = true 
		if main_window_appeared == false:
			$main_window.play_animation("appear")
			main_window_appeared = true
		$main_window.visible = true
		$Camera2D/button_console.visible = false
		$Camera2D/CanvasLayer/Control2.visible = false


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
	add_child(transition)
	new_scene_timer.start()
func new_scene_timer_timeout():
	get_tree().change_scene_to_file(incoming_scene)
func _on_settings_button_pressed() -> void:
	hide_elements
	camera_stop = true
	$Camera2D.position = initial_camera_position
	$shop.visible = false
	$owned_items.visible = false
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

func _on_idle_rider_animation_finished() -> void:
	var replay_delay = Timer.new()
	replay_delay.wait_time = 3.0
	replay_delay.autostart = false
	replay_delay.timeout.connect(replay_delay_timeout)
	add_child(replay_delay)
	replay_delay.start()
func replay_delay_timeout():
	$idle_rider.play(rider_name)

func _on_admob_rewarded_interstitial_watched() -> void:
	$Camera2D/button_console/profile_window_sprite.play("open")
	$Camera2D/CanvasLayer/Control3.visible = false
	$Camera2D/button_console/profile_button_sprite.play("normal")
	$suggest_ad_popup.reward_player()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if not event.position.x >= $suggest_ad_popup.get_node("TextureRect").position.x and not event.position.x <= $suggest_ad_popup.get_node("TextureRect").position.x + $suggest_ad_popup.get_node("TextureRect").size.x:
			$suggest_ad_popup.ignore()
		if not event.position.y < $suggest_ad_popup.get_node("TextureRect").position.y and not event.position.y <= $suggest_ad_popup.get_node("TextureRect").position.y + $suggest_ad_popup.get_node("TextureRect").size.y:
			$suggest_ad_popup.ignore()
	if event is InputEventScreenTouch and event.pressed:
		if not event.position.x >= $suggest_ad_popup.get_node("TextureRect").position.x and not event.position.x <= $suggest_ad_popup.get_node("TextureRect").position.x + $suggest_ad_popup.get_node("TextureRect").size.x:
			$suggest_ad_popup.ignore()
		if not event.position.y < $suggest_ad_popup.get_node("TextureRect").position.y and not event.position.y <= $suggest_ad_popup.get_node("TextureRect").position.y + $suggest_ad_popup.get_node("TextureRect").size.y:
			$suggest_ad_popup.ignore()
			


func _on_select_button_pressed() -> void:
	var upgrade = false
	var rider = false
	var vehicle_skin = false
	if selected_item["owned"] == false and selected_item["price"] != null:
		if global.stored_coins >= selected_item["price"]:
			global.buy(selected_item["price"], selected_item["name"])
	if selected_item["owned"] == true:
		for category in global.shop_catagories:
			if category["name"] == "purchaseable_upgrades":
				upgrade = true
			if category["name"] == "riders":
				rider = true
			if category["name"] == "vehicle_skins":
				vehicle_skin = true
			if category["name"] == selected_item["category"]:
				for item in category["items"]:
					if item["name"] != selected_item["name"]:
						item["equipped"] = false
					else:
						item["equipped"] = true
						if rider:
							global.current_rider = item["name"]
							print(global.current_rider)
						if vehicle_skin:
							global.current_vehicle_skin = item["name"]
							print(global.current_vehicle_skin)
						if upgrade:
							for upgrades in global.owned_purchaseable_upgrades:
								if upgrades == item["name"]:
									upgrades = global.owned_purchaseable_upgrades[0]
						
			else:
				print("not found")
func _on_item_display_window_animation_finished() -> void:
	if $Camera2D/button_console/item_display_window.animation == "hide":
		$Camera2D/CanvasLayer/info_display.visible = false
		$Camera2D/button_console/item_display_window.play("hidden")
	if $Camera2D/button_console/item_display_window.animation == "show":
		$Camera2D/button_console/item_display_window.play("shown")
		$Camera2D/CanvasLayer/info_display.visible = true

func update_info_display():
	for child in get_children():
		if child.name == "item_display" or child.name == "item_display_2":
			child.queue_free()

	match selected_item["category"]:
		"purchaseable_upgrades":
			pass
		"riders":
			var item_display = $idle_rider.duplicate()
			item_display.scale = Vector2(0.4, 0.4)
			item_display.play(selected_item["name"])
			if is_instance_valid($item_display):
				item_display.name = "item_display_2"
			else:
				item_display.name = "item_display"
			item_display.position = $main_window.get_node("item_display_location").position
			add_child(item_display)
			print(item_display.name)
		"vehicle_skins":
			var item_display = $idle_vehicle.duplicate()
			item_display.scale = Vector2(0.4, 0.4)
			item_display.play(selected_item["name"])
			if is_instance_valid($item_display):
				item_display.name = "item_display_2"
			else:
				item_display.name = "item_display"
				
			item_display.position = $main_window.get_node("item_display_location").position
			add_child(item_display)

func setup():
	$Camera2D/CanvasLayer/Control3.visible = false
	$main_window.visible = false
	$Camera2D/CanvasLayer/info_display.visible = false
	$backdop.position.y = window_size.y/2
	$backdop.position.x = window_size.x/2
	rider_name = global.current_rider
	vert_move = trueorfalse.pick_random()
	hori_move = not vert_move
	initial_camera_position = $Camera2D.global_position
	camera_movement_control()
	$idle_rider.play(rider_name)
	$shop.visible = false
	$owned_items.visible = false
	$backdop.position = $Camera2D.position
	$idle_vehicle.play(str(global.current_vehicle_skin))
	vehicle_size = $idle_vehicle.sprite_frames.get_frame_texture(str(global.current_vehicle_skin), 0).get_size()
	$idle_vehicle.position = initial_camera_position
	$idle_vehicle.position.y -= vehicle_size.y/4
func hide_elements():
	for element in hidden_elements:
		element.visible = false
func reveal_elements():
	for element in hidden_elements:
		element.visible = true

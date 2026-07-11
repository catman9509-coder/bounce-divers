extends CanvasLayer
var game_menu : PackedScene = load("res://death_menu.tscn")
var game_menu_background : PackedScene = load("res://death_background.tscn")
var can_play_collision_animation = true
var can_play_extermination_animation = true



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Control/money.text = "money collected: " + str(global.gathered_coins)
	$Control/HBoxContainer/score.text = "parsecs: " + str(global.score)
	$emergency_shift/Button/Label.text = "x" + str(global.shift_fuel_count)	
	if global.shift_fuel_count > 0 :
		$emergency_shift.visible = true
	else:
		$emergency_shift.visible = false

	show_collision_count()
	if global.payed == true:
		$AnimationPlayer2.play("money_gain")
	if global.exterminations > 0:
		check_exterminations()
		
		
		
	


func _on_menu_button_pressed() -> void:
	
	var background = game_menu_background.instantiate()
	get_parent().add_child(background)
	background.get_node("AnimationPlayer").play("normal")
	var menu = game_menu.instantiate()
	get_parent().add_child(menu)
	menu.position = Vector2(360/2, 640/2)
	menu.get_node("AnimationPlayer").play("appear")



func _on_menu_button_released() -> void:
	pass
	
	
	
	


func _on_stored_upgrade_button_pressed() -> void:
	if global.owned_purchaseable_upgrades.size() > 0:
		if global.owned_purchaseable_upgrades[0]:
			global.upgrade(global.owned_purchaseable_upgrades[0])
			for upgrades in global.shop_catagories[2]["items"]:
				if upgrades["name"] == global.owned_purchaseable_upgrades[0]:
					upgrades["owned"] = false
			global.owned_purchaseable_upgrades.pop_at(0)
			
		else:
			print("no upgrade")
			


func _on_button_pressed() -> void:
	global.shift = true
func show_collision_count():
	if global.in_game_collisions > 1 and global.health > 0:
		if can_play_collision_animation:
			$AnimationPlayer.play("collision_message_appearance")
			$collisions_label.text = "collisions : " + str(global.in_game_collisions)
			global.pay_for_cleaning(int(global.in_game_collisions/2))
			can_play_collision_animation = false
		
		
		
func in_game_message(event):
	match event:
		"cum":
			pass
		_:
			pass
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "collision_message_appearance":
		if global.in_game_collisions <=1:
			$collisions_label.text = " "
			can_play_collision_animation = true
	if anim_name == "extermination_message_appearance":
		if global.exterminations <= 1:
			$extermination_label.text = " "
			can_play_extermination_animation = true
			
	if anim_name == "money_gain":
		global.payed = false
func check_exterminations():
	if can_play_extermination_animation:
		$message_timer.wait_time = global.exterminations/10
		$message_timer.start()
		$AnimationPlayer.play("extermination_message_appearance")
		$extermination_label.text = "X" + str(global.exterminations) + " exterminations"
		global.pay_for_cleaning(global.exterminations)
	can_play_extermination_animation = false

			
		


func _on_message_timer_timeout() -> void:
	global.exterminations = 0
	$message_timer.wait_time = 0.2

extends Node
#global assets 
var transition_sprite : PackedScene = load("res://transition_sprites.tscn")
#save and load data	
var user_id = null
var user_name = "player"
var password = "password"
var current_rider 
var current_vehicle_skin 
var owned_purchaseable_upgrades = []
var high_score = 0
var stats = {
	"high_score": high_score
}

var death_screen = true
var settings = {
	"death_screen": death_screen
}

var stored_coins = 1000

#shop variables v
var vehicle_skins = [
	{"name" : "model 2", "icon" : "none", "description" : "lorem ipsum", "rarity" : "common", "owned" : false, "equipped" : false},
	{"name" : "model 1", "icon" : "none", "description" : "lorem ipsum", "rarity" : "common", "owned" : true, "equipped" : true}
]
var riders = [
	{"name" : "tin head", "icon" : "none", "description" : "lorem ipsum", "rarity" : "common", "owned" : false, "equipped" : false},
	{"name" : "freelancer", "icon" : "none", "description" : "lorem ipsum", "rarity" : "common", "owned" : true, "equipped" : true}
]
var purchaseable_upgrades = [
	{"name" : "extra life", "icon" : "none", "description" : "lorem", "rarity" : "common", "owned" : false, "equipped" : false},
	{"name" : "soap_bar_upgrade", "icon" : "none", "description" : "lorem", "rarity" : "common", "owned" : false, "equipped" : false},
	{"name" : "soap_bomb_upgrade", "icon" : "none", "description" : "lorem", "rarity" : "epic", "owned" : false, "equipped" : false},
	{"name" : "immunity_upgrade", "icon" : "none", "description" : "lorem", "rarity" : "epic", "owned" : false, "equipped" : false}
	
]
var shop_catagories = [
	{"name" : "vehicle_skins", "items" : vehicle_skins},
	{"name" : "riders", "items" : riders},
	{"name" : "purchaseable_upgrades", "items" : purchaseable_upgrades}
	]
	#riders, 
#purchaseable_upgrades
var purchase_made = ""
var purchase_category = ""

#shop variables ^
#screen mainpulation
var actuall_screen = DisplayServer.screen_get_size()
var screen_scale = DisplayServer.screen_get_scale()
var screen_pos = DisplayServer.screen_get_position()
# inventory


#player variables
var shift_pressed = false
var shift : bool
var shift_fuel_count = 1
var go_up = false
var go_down = false
var player_position
var player_attacked
var player_attack = false
var health
var can_be_attacked = true
var immunity_duration = 1.0
var state : String
var states = ["base", "soap_bar_upgrade", "soap_bomb_upgrade", "immunity_upgrade", "rocket_burst_upgrade", "magnet"]
var enemy_up = false
var enemy_down = false
var normalize = false
var extra_life = false
# score anc coin variables
var score = 0
var gathered_coins

#game_variables
var popup_message : PackedScene = load("res://message.tscn")
var death = false
var game_started = false
var start_game = false
var start_motion = false
var difficulty = 4.0
var player_start_direction = ""
var left_barriers = []
var right_barriers = []
var spawned_objects = []
var current_barriers = []
# in game ui pop ups
var exterminations = 0
var in_game_collisions = 0
var payed = false

var finish_transition = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = 2
	score = 0
	gathered_coins = 0
	for vehicle_skin in vehicle_skins:
		if vehicle_skin["equipped"] == true:
			current_vehicle_skin = vehicle_skin["name"]
	for rider in riders:
		if rider["equipped"] == true:
			current_rider = rider["name"]

	
func update_difficulty():
	match score:
		50:
			difficulty = 4.5
		100:
			difficulty = 4.0
		500:
			difficulty = 3.0
		1000:
			difficulty = 2.8
		2000:
			difficulty = 2.5
		_:
			difficulty = 5.0
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func attacked(lost_health):
	if can_be_attacked:
		player_attacked = true
		health -= lost_health
		immunity_duration = 1.0
		immunity_time(immunity_duration)
		state = states[0]

func immunity_time(immunity_duration):
	can_be_attacked = false
	var immunity_timer = Timer.new()
	immunity_timer.wait_time = immunity_duration
	immunity_timer.one_shot = true
	immunity_timer.timeout.connect(immunity_timeout)
	add_child(immunity_timer)
	immunity_timer.start()
func immunity_timeout():
	can_be_attacked = true
	
func pay_for_cleaning(coins):
	if health > 0:
		gathered_coins += coins
		stored_coins += coins
		payed = true
func upgrade(upgrade_name):
	
	var current_upgrade : StringName = upgrade_name
	match current_upgrade:
		"soap_bar_upgrade":
			state = states[1]
		"soap_bomb_upgrade":
			state = states[2]
		"immunity_upgrade":
			state = states[3]
		"rocket_burst_upgrade":
			state = states[4]
		"magnet_upgrade":
			state = states[5]
		_:
			pass
	if health < 3:
		health += 1
	print(state)
			
func buy(price, item_name):
	var upgrade
	for category in shop_catagories:
		if category["name"] == "purchaseable_upgrades":
			upgrade = true
		else:
			upgrade = false
		for item in category["items"]:
			if item["name"] == item_name:
				if item["owned"] == false:
					stored_coins -= price	
					print("bought" + item["name"])
					if upgrade:
						owned_purchaseable_upgrades.append(item["name"])
						item["owned"] = true	
					item["owned"] = true
					self.purchase_made = item["name"]
					self.purchase_category = category["name"]
					print(item["owned"])
					
				else:
					print( item["name"] + " " + "already owned")
				save_manager.save()
func message(msg, anim, position):
	var mesg = popup_message.instantiate()
	mesg.msg = msg
	mesg.anim = anim
	if get_parent():
		get_parent().add_child(mesg)
		mesg.global_position = position
		if get_parent().has_node("message_layer"):
			get_parent().get_node("message_layer").add_child(mesg)
			
	else: 
		add_child(mesg)
		mesg.global_position = position
func transition_animation(scene):
	var sprite = transition_sprite.instantiate()
	sprite.scene = scene
	get_tree().current_scene.add_child(sprite)
	sprite.position.x = 0
	sprite.get_node("AnimationPlayer").play("normal_transition")
	finish_transition = true
			
func scene_change_transition():
	if finish_transition == true:
		var sprite = transition_sprite.instantiate()
		get_tree().current_scene.add_child(sprite)
		print("sprite added to current scene")
		sprite.position.x = 0
		sprite.get_node("AnimationPlayer").play("scene_changed")
	finish_transition = false
		
	
	

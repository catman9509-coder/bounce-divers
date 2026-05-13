extends Node

#save and load data	
var user_name = "player"
var password = "null"
var current_rider 
var current_vehicle_skin 
var owned_purchaseable_upgrades = []
var high_score = 0
var stored_coins = 1000

#shop variables v
var vehicle_skins = [
	{"name" : "model 2", "icon" : "none", "description" : "lorem ipsum", "rarity" : "common", "owned" : false, "equipped" : false},
	{"name" : "default", "icon" : "none", "description" : "lorem ipsum", "rarity" : "common", "owned" : true, "equipped" : true}
]
var riders = [
	{"name" : "tin head", "icon" : "none", "description" : "lorem ipsum", "rarity" : "common", "owned" : false, "equipped" : false},
	{"name" : "default", "icon" : "none", "description" : "lorem ipsum", "rarity" : "common", "owned" : true, "equipped" : true}
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

#shop variables ^

# inventory

#toggleable variable
var death_screen = true
var toggleable_variable = [death_screen]
#player variables
var shift = false
var go_up = false
var go_down = false
var player_position
var player_attacked
var player_attack = false
var health
var can_be_attacked = true
var immunity_duration = 1.0
var state : String
var base_upgrades = ["none","base", "rocket_burst_upgrade", "magnet"]
var base_state : String
var states = ["base", "soap_bar_upgrade", "soap_bomb_upgrade", "immunity_upgrade"]
var enemy_up = false
var enemy_down = false
var normalize = false
var extra_life = false
# score anc coin variables
var score = 0
var gathered_coins

#game_variables
var death = false
var game_started = false
var start_game = false
var start_motion = false
var difficulty = 4.0
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
func _process(delta: float) -> void:
	pass
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
	normalize = true
func immunity_timeout():
	can_be_attacked = true
		
func pay_for_cleaning(coins):
	
	gathered_coins += coins
	stored_coins += coins
func upgrade(upgrade_name):
	
	var upgrade : String = upgrade_name
	match upgrade:
		"soap_bar_upgrade":
			state = states[1]
		"soap_bomb_upgrade":
			state = states[2]
		"immunity_upgrade":
			state = states[3]
		"rocket_burst_upgrade":
			base_state = base_upgrades[2]
		"magnet_upgrade":
			base_state = base_upgrades[3]
		"base_upgrade":
			base_state = base_upgrades[1]
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
					print(item["owned"])
					
				else:
					print( item["name"] + " " + "already owned")
				save_manager.save()
				
		

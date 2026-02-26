extends Node
#toggleable variable
var death_screen = true
#player variables
var player_position
var player_attacked
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
# score anc coin variables
var score
var stored_coins
var gathered_coins

#game_variables
var game_started = false
var start_game = false
var start_motion = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = 2
	score = 0
	gathered_coins = 0


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
func death():
	pass
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
	if health < 3:
		health += 1
	print(state)
				

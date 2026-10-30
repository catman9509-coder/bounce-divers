extends Popup
var possible_rewards = ["credits", "upgrade"]
var range = randi_range(1, 200)
var parent_scene = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_ignore_button_pressed() -> void:
	ignore()
func ignore():
	get_parent().ad_suggestion_closed = true
	var new_suggestion_timer = Timer.new()
	new_suggestion_timer.wait_time = randi_range(1000.0, 4000.0)
	new_suggestion_timer.timeout.connect(new_suggestion_timeout)
	new_suggestion_timer.one_shot = true
	add_child(new_suggestion_timer)
	new_suggestion_timer.start()
func new_suggestion_timeout():
	get_parent().ad_suggestion_closed = false
func reward_player():
	var reward = possible_rewards[randi() % possible_rewards.size()]
	var upgrade_found = false
	match reward:
			"credits":
				var payment_amount = range
				global.pay_for_cleaning(payment_amount)
				$message.text = " + " +  str(payment_amount) + " credits"
			"upgrade":
				for upgrade in global.purchaseable_upgrades:
					if upgrade["name"] not in global.purchaseable_upgrades and upgrade["owned"] == false and upgrade_found == false:
						upgrade_found = true
						upgrade["owned"] = true
						global.owned_purchaseable_upgrades.append(upgrade["name"])
						$message.text = "+ " + upgrade["name"]

	
func _on_watch_button_pressed() -> void:
	get_parent().watching_rewarded_interstitial_ad = true

extends CanvasLayer
var game_menu : PackedScene = load("res://death_menu.tscn")
var game_menu_background : PackedScene = load("res://death_background.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Control/HBoxContainer/money.text = "money collected: " + str(global.gathered_coins)
	$Control/HBoxContainer/money/score.text = "parsecs: " + str(global.score)


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

extends CanvasLayer
var shop_catagory :PackedScene = preload("res://shop_catageory.tscn")
var shop_item : PackedScene = preload("res://shop_item.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(global.owned_purchaseable_upgrades)
	for category in global.shop_catagories:
		var upgrade
		var shop_cat = shop_catagory.instantiate()
		shop_cat.get_node("category_name").text = category["name"]
		if category["name"] == "purchaseable_upgrades":
			for shop_upgrade in category["items"]:
				if shop_upgrade["owned"] == true and shop_upgrade["name"] not in global.owned_purchaseable_upgrades:
					shop_upgrade["owned"] = false
			for upgrades in global.purchaseable_upgrades:
				if upgrades["owned"] == true and upgrades["name"] not in global.owned_purchaseable_upgrades:
					upgrades["owned"] = false
				if global.owned_purchaseable_upgrades.has(upgrades["name"]) and upgrades["owned"] == false:
					upgrades["owned"] = true
				print(global.owned_purchaseable_upgrades)
				print(global.purchaseable_upgrades[0])
			upgrade = true
		else:
			upgrade = false
		for item in category["items"]:
			if upgrade:
				pass
					
			
			if item["owned"] == true:
				var new_item = shop_item.instantiate()
				new_item.category = category["name"]
				new_item.owned = true
				var item_name = str(item["name"])
				new_item.item_name = item_name
				new_item.rarity = item["rarity"]
				shop_cat.get_node("ScrollContainer/HBoxContainer").add_child(new_item)
			
		$Control/VBoxContainer.add_child(shop_cat)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Control/MarginContainer/HBoxContainer/balance.text = str(global.stored_coins)
	

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")

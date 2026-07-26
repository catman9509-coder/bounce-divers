extends CanvasLayer
var shop_catagory :PackedScene = preload("res://shop_catageory.tscn")
var shop_item : PackedScene = preload("res://shop_item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for category in global.shop_catagories:
		var shop_cat = shop_catagory.instantiate()
		shop_cat.get_node("category_name").text = category["name"]

		for item in category["items"]:
			if item["owned"] == false:
				var new_item = shop_item.instantiate()
				if item["owned"] == false:
					new_item.owned = false
					new_item.not_owned = true
				else:
					new_item.not_owned = false
					new_item.owned = true
				var item_name = str(item["name"])
				new_item.category = category["name"]
				new_item.item_name = item_name
				new_item.rarity = item["rarity"]
				new_item.description = item["description"]
				shop_cat.get_node("ScrollContainer/HBoxContainer").add_child(new_item)
			 
			
		$Control/VBoxContainer.add_child(shop_cat)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Control/MarginContainer/HBoxContainer/balance.text = ("current credits : " + str(global.stored_coins))

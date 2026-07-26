extends CanvasLayer
var shop_catagory :PackedScene = preload("res://shop_catageory.tscn")
var shop_item : PackedScene = preload("res://shop_item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for category in global.shop_catagories:
		var shop_cat = shop_catagory.instantiate()
		shop_cat.get_node("category_name").text = category["name"]

		for item in category["items"]:
			var new_item = shop_item.instantiate()
			var item_name = str(item["name"])
			new_item.item_name = item_name
			new_item.rarity = item["rarity"]
			shop_cat.add_child(new_item)
			
			
		$Control/VBoxContainer.add_child(shop_cat)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Control/MarginContainer/HBoxContainer/balance.text = str(global.stored_coins)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")

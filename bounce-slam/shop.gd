extends CanvasLayer
var shop_catagory :PackedScene = preload("res://shop_catageory.tscn")
var shop_item : PackedScene = preload("res://shop_item.tscn")

var current_scene
var window_type = Sub_window.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_scene = get_tree().current_scene
	if current_scene.name == "main_menu":
		window_type.window_rect = $Control
		#window_type.fix_anchors()
		window_type.target_size = current_scene.get_node("main_window").get_node("sub_window_space").size
		window_type.fix_size()
		$Control.custom_maximum_size = $Control.size
		$Control.global_position = current_scene.get_node("main_window").get_node("sub_window_space").global_position
	load_items()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global.purchase_made != "":
		update_shop_items()
func update_shop_items():
	for shop_category in $Control/VBoxContainer.get_children():
		if shop_category.name == global.purchase_category:
			for item in shop_category.get_node("ScrollContainer/HBoxContainer").get_children():
				if item.item_name == global.purchase_made:
					item.queue_free()
func load_items():
	for category in global.shop_catagories:
		var shop_cat = shop_catagory.instantiate()
		shop_cat.name = category["name"]
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

extends TextureButton
var item_info : PackedScene = load("res://item_info.tscn")
var item_name = "item"
var description : String
var category : String
var icon
var rarity = " "
var price = 0
var owned
var not_owned


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anchor_left = 0
	anchor_right = 1
	anchor_top = 0
	anchor_bottom = 1
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
	size_flags_horizontal = SIZE_EXPAND
	size_flags_vertical = SIZE_EXPAND
	custom_minimum_size = Vector2(0, 0)
	#self.custom_maximum_size = get_parent().get_size()
#	print(category)
	if owned:
		$price.visible = false
		print("owned")
	else:
		print("not owned")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$item_name.text = item_name
	match (rarity):
		"common":
			price = 200
		"rare":
			price = 400
		"epic":
			price = 800
		"legendary":
			price = 1600
		_:
			price = 300

	$price.text = str(price)

func _on_pressed() -> void:
	
	var current_scene = get_tree().current_scene
	var info_popup = item_info.instantiate()
	if owned == true:
		info_popup.owned = true
		info_popup.not_owned = false
	if not_owned == true:
		info_popup.not_owned = true	
		info_popup.owned = false
	if current_scene.name == "main_menu":
		
		current_scene.selected_item["name"] = self.item_name
		current_scene.selected_item["category"] = self.category
		current_scene.selected_item["price"] = self.price
		current_scene.selected_item["description"] = self.description
		
		if owned:
			current_scene.selected_item["owned"] = true
		elif not_owned:
			current_scene.selected_item["owned"] = false
		current_scene.update_info_display()
		

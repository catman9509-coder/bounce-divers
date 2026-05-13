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
	print(category)
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
	
	var info_popup = item_info.instantiate()
	if owned == true:
		info_popup.owned = true
		info_popup.not_owned = false
	if not_owned == true:
		info_popup.not_owned = true	
		info_popup.owned = false
	info_popup.cat = str(category)
	info_popup.item_name = item_name
	info_popup.description = description
	info_popup.price = price 
	get_parent().get_parent().get_parent().get_parent().get_parent().add_child(info_popup)
	info_popup.global_position.x = get_viewport_rect().size.x/4.5
	info_popup.global_position.y = get_viewport_rect().size.y/4
	
	

extends Control
var image
var item_name = "poop "
var description = " "
var price = 0
var info_space_x
var info_space_y
var owned
var not_owned
var cat : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	info_space_x = $ColorRect.size.x
	info_space_y = $ColorRect.size.y
	$item_name.text = item_name
	$item_description.text = description
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.position.x > position.x+info_space_x or event.position.x < position.x:
			self.queue_free()
		if event.position.y > position.y+info_space_y or event.position.y < position.y:
			self.queue_free()
	if event is InputEventScreenTouch and event.pressed:
		if event.position.x > position.x+info_space_x or event.position.x < position.x:
			self.queue_free()
		if event.position.y > position.y+info_space_y or event.position.y < position.y:
			self.queue_free()
			

func _on_buy_button_pressed() -> void:
	var upgrade = false
	var rider = false
	var vehicle_skin = false
	if not_owned:
		if global.stored_coins >= price:
			global.buy(price, item_name)
	if owned:
		for category in global.shop_catagories:
			if category["name"] == "purchaseable_upgrades":
				upgrade = true
			if category["name"] == "riders":
				rider = true
			if category["name"] == "vehicle_skins":
				vehicle_skin = true
			if category["name"] == str(cat):
				for item in category["items"]:
					if item["name"] != item_name:
						print("unequipped all")
						item["equipped"] = false
					else:
						item["equipped"] = true
						print("item_equipped")
						if rider:
							global.current_rider = item["name"]
							print(global.current_rider)
						if vehicle_skin:
							global.current_vehicle_skin = item["name"]
							print(global.current_vehicle_skin)
						if upgrade:
							for upgrades in global.owned_purchaseable_upgrades:
								if upgrades == item["name"]:
									upgrades = global.owned_purchaseable_upgrades[0]
						
			else:
				print("not found")
						
		
		
		
	

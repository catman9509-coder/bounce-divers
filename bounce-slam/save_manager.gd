extends Node
var save_path = "user://variable.save"

var http_attached := false
var user_id : int = -1
var can_register = false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print_tree()

	print("SaveManager READY")
	_wait_for_scene()
	load_data()
	
	#pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _wait_for_scene() -> void:
	await get_tree().process_frame

	# Wait until the first scene is loaded
	while get_tree().current_scene == null:
		await get_tree().process_frame

	# Now the scene exists — do your setup HERE
	print("Scene loaded:", get_tree().current_scene.name)
	get_tree().current_scene.add_child($http)
	get_tree().current_scene.add_child($http_request_create_inventory)
	get_tree().current_scene.add_child($http_request_verify_username)
	get_tree().current_scene.add_child($http_request_login)
	get_tree().current_scene.add_child($http_request_register)
	get_tree().current_scene.add_child($http_request_user)
	get_tree().current_scene.add_child($http_request_inventory)
	$http.request_completed.connect(_on_request_completed)
	$http_request_verify_username.request_completed.connect(_on_http_request_verify_username_request_completed)
	$http_request_create_inventory.request_completed.connect(_on_http_request_create_inventory_request_completed)
	$http_request_user.request_completed.connect(_on_http_request_user_request_completed)
	$http_request_inventory.request_completed.connect(_on_http_request_inventory_request_completed)
	$http_request_login.request_completed.connect(_on_http_request_login_request_completed)
	$http_request_register.request_completed.connect(_on_http_request_register_request_completed)
	_send_test_request()

func _on_registered_response(result, code, headers, body):
	var text = body.get_string_from_utf8()
	var data = JSON.parse_string(text);
	if data.success:
		userdata.user_id = data.user_id
		user_id = userdata.user_id
	
func _send_test_request():
	print("sending request ... ")
	$http.request("http://127.0.0.1:3000/test")
func _on_request_completed(result, response_code, headers, body):
	print("RESULT:", result)
	print("CODE:", response_code)
	print("BODY:", body.get_string_from_utf8())
	var text = body.get_string_from_utf8()
	print("response: ", text)

func create_user():
	var headers = ["Content-Type: application/json"]
	var body = {
		"user_id" : save_manager.user_id,
		"username": global.user_name,
		"password": global.password,
		"stats": {"high_score": global.high_score},
		"settings": global.toggleable_variable
	}
	var text = body
	$http_request_create_user.request("http://127.0.0.1:3000/save_user", headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	print("METHOD USED:", $http_request_verify_username.get_http_client_status())
	print("RAW TEXT:", text)
	print("SENDING:", JSON.stringify(body))
func create_inventory():
	var headers = ["Content-Type: application/json"]
	var body = {
		"user_id" : save_manager.user_id,
		"owned_riders": global.riders ,
		"owned_vehicle_skins": global.vehicle_skins,
		"owned_purchaseable_upgrades": global.purchaseable_upgrades,
		"credits": global.stored_coins
	}
	$http_request_create_inventory.request("http://127.0.0.1:3000/create_inventory", headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	
func logged_in_save():
	var user_data = {
		"username": global.user_name,
		"password": global.password,
		"stats": {"high_score": global.high_score},
		"settings": global.toggleable_variable
	}
	$http.request("http://127.0.0.1:3000/save_user", [], HTTPClient.METHOD_POST, JSON.stringify(user_data))
	var inventory_data = {
		"user_id" : save_manager.user_id,
		"owned_riders": global.riders,
		"owned_vehicle_skins": global.vehicle_skins,
		"owned_purchaseable_upgrades": global.purchaseable_upgrades,
		"credits": global.stored_coins
	}
	$http.request("http://127.0.0.1:3000/save_inventory", [], HTTPClient.METHOD_POST, JSON.stringify(inventory_data))
#http requests for user and inventory

# non database saves and loads
func save():
	var data = {
		"user_name": global.user_name,
		"password": global.password,
		"vehicle_skins": global.vehicle_skins,
		"riders": global.riders,
		"shop_catagories": global.shop_catagories,
		"purchaseable_upgrades": global.purchaseable_upgrades,
		"current_rider": global.current_rider,
		"current_vehicle_skin": global.current_vehicle_skin,
		"high_score": global.high_score,
		"stored_coins": global.stored_coins,
		"owned_purchaseable_upgrades": global.owned_purchaseable_upgrades
		}
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(data)
	file.close()
	if userdata.is_logged_in:
		logged_in_save()
		
	
func load_data():
	if not FileAccess.file_exists(save_path) or FileAccess.open(save_path, FileAccess.READ) == null:
		print("no save found")
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var data = file.get_var()
		file.close()
		global.user_name = data["user_name"]
		global.vehicle_skins = data["vehicle_skins"]
		global.riders = data["riders"]
		global.shop_catagories = data["shop_catagories"]
		global.purchaseable_upgrades = data["purchaseable_upgrades"]
		global.current_rider = data["current_rider"]
		global.current_vehicle_skin = data["current_vehicle_skin"]
		global.high_score = data["high_score"]
		global.stored_coins = data["stored_coins"]
		global.owned_purchaseable_upgrades = data["owned_purchaseable_upgrades"]
		print(str(global.riders))
		
	else:
		print("no save found")
	if userdata.is_logged_in:
		load_user_save_data()
		load_user_inventory_data()
#send request
func load_user_save_data():
	var url = "http://localhost:3000/load_user"
	var body = {"user_id" : userdata.user_id}
	$http_request_user.request(url, [], HTTPClient.METHOD_GET, JSON.stringify(body))
	
func load_user_inventory_data():
	var url = "http://localhost:3000/load_inventory"
	var body = {"user_id" : userdata.user_id}
	$http_request_inventory.request(url, [], HTTPClient.METHOD_GET, JSON.stringify(body))

func verify_user_name():
	var headers = ["Content-Type: application/json"]
	var url = "http://localhost:3000/check_username"
	var body = {"username" : userdata.username}
	var text = body
	$http_request_verify_username.request(url, headers,HTTPClient.METHOD_POST,JSON.stringify(body))
	print("METHOD USED:", $http_request_verify_username.get_http_client_status())
	print("RAW TEXT:", text)
	print("SENDING:", JSON.stringify(body))
func login_user():
	var url = "http://localhost:3000/login"
	var body = {"username" : userdata.username, "password" : userdata.password}	
	var headers = ["Content-Type: application/json"]
	$http_request_login.request(url, headers, HTTPClient.METHOD_POST,JSON.stringify(body))
	print($http_request_login)
func register_user():
	var url = "http://localhost:3000/register"
	var headers = ["Content-Type: application/json"]
	var body = {
		"username": global.user_name,
		"password": global.password,
		"stats": {"high_score": global.high_score},
		"settings": {"settings" : global.toggleable_variable}
	}
	$http_request_register.request(url, headers,HTTPClient.METHOD_POST,JSON.stringify(body))
	
# handle request

func _on_http_request_user_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var text = body.get_string_from_utf8()
	var data = JSON.parse_string(text)
	if data and data.success:
		global.stats = data.stats
		global.settings = data.settings
		print("data found: " + str(data))
	else:
		print("no data found: " + text)
	
func _on_http_request_inventory_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	
	var text = body.get_string_from_utf8()
	var data = JSON.parse_string(text)
	if data and data.success:
		global.riders = data.owned_riders
		global.vehicle_skins = data.owned_vehicle_skins
		global.purchaseable_upgrades = data.owned_purchaseable_upgrades
		global.stored_coins = data.credits
		print("data found: " + str(data))
	else:
		print("no data found: " + text)
func _on_http_request_login_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var text = body.get_string_from_utf8()
	var data = JSON.parse_string(text)
	if data:
		print("trying to login ")
	if data and data.success:
		userdata.user_id = data.user_id
		save_manager.user_id = userdata.user_id
		load_user_save_data()
		load_user_inventory_data()
	else:
		print("no data")
		
		
func _on_http_request_register_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var text = body.get_string_from_utf8()
	var data = JSON.parse_string(text)
	if data and data.success:
		userdata.user_id = data.user_id
		save_manager.user_id = userdata.user_id
		print(user_id)
		create_inventory()
		
		#load_user_save_data()
		#load_user_inventory_data()
		

func _on_http_request_verify_username_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var text = body.get_string_from_utf8()
	var data = JSON.parse_string(text)
	print("METHOD USED:", $http_request_verify_username.get_http_client_status())
	print("RAW TEXT:", text)
	print("SENDING:", JSON.stringify(body))
	print("RAW TEXT:", text)
	if data and data.exists == false:
		can_register = true
		print("registering ninja")
	if data:
		print("data exists")
		register_user()
		
	else:
		can_register = false
		print("not registering ninja")
		
		


func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	pass # Replace with function body.


func _on_http_request_create_inventory_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var text = body.get_string_from_utf8()
	var data = JSON.parse_string(text)
	print("inventory created")
	if data:
		print("data went through")
	if data and data.success:
		print("inventory create my ninja")
	else:
		print("inventory not created")
		
		

extends Popup
var body 
var message : PackedScene = preload("res://message.tscn")
var buffering_icon : PackedScene = preload("res://loading_icon.tscn")
var logging_in = false
var registering = false
var loading = false

var json
var pop = true
var submit_pressed = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#pop = false



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		
	if pop:
		popup()
		self.popup_centered()
	else:
		pass
	if userdata.is_logged_in:
		if loading:
			for child in get_children():
				if child.has_method("fadeout"):
					pop_message("logged in", "faded")
					child.fadeout()
			loading = false
		if pop:
			pop = false
		
func _on_username_input_text_submitted(new_text: String) -> void:
	pass


func _on_password_input_text_submitted(new_text: String) -> void:
	pass




func _on_submit_pressed() -> void:
	submit_pressed = true
	if submit_pressed and not userdata.is_logged_in and loading == false:
		loading = true
		var buffering = buffering_icon.instantiate()
		buffering.position = get_visible_rect().get_center()
		add_child(buffering)
	$username_input.grab_focus()
	$password_input.grab_focus()
	if logging_in:
		print("login pressed")
		save_manager.login_user()
	if registering:
		save_manager.verify_user_name()
		print("eat poop")
		if save_manager.can_register:
			save_manager.register_user()
	#else:
	#	print("error")
	
	


func _on_username_input_text_changed(new_text: String) -> void:
	userdata.username = $username_input.text
	global.user_name = userdata.username
	print("username changes")


func _on_password_input_text_changed(new_text: String) -> void:
	userdata.password = $password_input.text
	global.password = userdata.password


func _on_login_pressed() -> void:
	pop_message("logging in", "faded")
	logging_in = true
	registering = false
	print("logging in")
	

func _on_register_pressed() -> void:
	pop_message("registering", "faded")
	registering = true
	logging_in = false
	print("registering")
func pop_message(msg, anim):
	var mesg = message.instantiate()
	mesg.msg = msg
	mesg.anim = anim
	add_child(mesg)
	mesg.position = get_visible_rect().get_center()
	mesg.position.x -= mesg.get_node("TextureRect").size.x

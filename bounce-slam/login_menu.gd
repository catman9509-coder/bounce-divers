extends Popup
var body 
var logging_in = false
var registering = false
var json
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = true
	self.popup()
	self.popup_centered()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	popup()


func _on_username_input_text_submitted(new_text: String) -> void:
	pass


func _on_password_input_text_submitted(new_text: String) -> void:
	pass




func _on_submit_pressed() -> void:
	$username_input.grab_focus()
	$password_input.grab_focus()
	if logging_in:
		save_manager.login_user()
	if registering:
		save_manager.verify_user_name()
		print("eat poop")
		if save_manager.can_register:
			save_manager.register_user()
	else:
		print("error")
	
	


func _on_username_input_text_changed(new_text: String) -> void:
	userdata.username = $username_input.text
	global.user_name = userdata.username
	print("username changes")


func _on_password_input_text_changed(new_text: String) -> void:
	userdata.password = $password_input.text
	global.password = userdata.password


func _on_login_pressed() -> void:
	logging_in = true
	registering = false
	print("logging in")
	

func _on_register_pressed() -> void:
	registering = true
	logging_in = false
	print("registering")

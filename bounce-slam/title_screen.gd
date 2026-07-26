extends CanvasLayer
var fade_out : PackedScene = preload("res://death_background.tscn")
var message : PackedScene = preload("res://message.tscn")

var can_transition = true

var menu_open = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$login_menu.pop = false
	$player_username.text = "welcome : " + userdata.username


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	
	var transition_timer = Timer.new()
	transition_timer.wait_time = 1.0
	transition_timer.one_shot = true
	transition_timer.timeout.connect(transition_timeout)
	add_child(transition_timer)
	var transition = fade_out.instantiate()
	if can_transition:
		if event is InputEventMouseButton and event.pressed:
			if $login_register_button.get_global_rect().has_point(event.position) and $login_menu.pop == false:
				$login_menu.pop = true
			elif $login_menu.pop:
				if event.position.x > $login_menu.position.x+$login_menu.get_node("TextureRect").size.x or event.position.x < $login_menu.position.x:
					$login_menu.pop = false
				if event.position.y > $login_menu.position.y+$login_menu.get_node("TextureRect").size.y or event.position.y < $login_menu.position.y:
					$login_menu.pop = false
			else: 
				$login_menu.pop = false
				transition_timer.start()
				add_child(transition)
				transition.get_node("AnimationPlayer").play("fade_out")
				can_transition = false
			
		if event is InputEventScreenTouch and event.pressed:
			if $login_register_button.get_global_rect().has_point(event.position) and $login_menu.pop == false:
				$login_menu.pop = true
			elif $login_menu.pop:
				if event.position.x > $login_menu.position.x+$login_menu.get_node("TextureRect").size.x or event.position.x < $login_menu.position.x:
					$login_menu.pop = false
				if event.position.y > $login_menu.position.y+$login_menu.get_node("TextureRect").size.y or event.position.y < $login_menu.position.y:
					$login_menu.pop = false
			else: 
				$login_menu.pop = false
				transition_timer.start()
				add_child(transition)
				transition.get_node("AnimationPlayer").play("fade_out")
				can_transition = false
		
func transition_timeout():
	print("done")
	get_tree().change_scene_to_file("res://main_menu.tscn")
	
	


func _on_login_register_button_pressed() -> void:
	pass
	

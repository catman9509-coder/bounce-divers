extends CanvasLayer
var message : PackedScene = preload("res://message.tscn")

var can_transition = true

var menu_open = false
var hideable_items = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hideable_items = [$Control, $Control2, $login_register_button, $player_username]
	for item in hideable_items:
		item.visible = true
	$login_menu.pop = false
	$player_username.text = "welcome : " + userdata.username


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
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
				for item in hideable_items:
					item.visible = false
				$login_menu.pop = false
				global.transition_animation("res://main_menu.tscn")
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
				for item in hideable_items:
					item.visible = false
				$login_menu.pop = false
				global.transition_animation("res://main_menu.tscn")
				can_transition = false
		
	
	


func _on_login_register_button_pressed() -> void:
	pass
	

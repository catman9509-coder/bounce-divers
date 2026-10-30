extends Control
var rect_size 
var current_scene
func _ready():
	current_scene = get_tree().current_scene
	rect_size = $ColorRect.size
		
func _on_play_again_pressed() -> void:
	if current_scene.name == "level":
		current_scene.rider_has_been_ejected = false
		current_scene.get_node("Camera2D").zoom = Vector2(1.0, 1.0)
		current_scene.get_node("Camera2D").position = current_scene.initial_camera_pos
		self.position = Vector2(get_viewport().get_visible_rect().size.x, 0)
	if get_tree().paused == true:
		get_tree().paused = false
	global.transition_animation("res://level.tscn")
	self.visible = false
	global.start_game = false
	global.health = 2
		


func _on_main_menu_pressed() -> void:
	if current_scene.name == "level":
		current_scene.rider_has_been_ejected = false
		current_scene.get_node("Camera2D").zoom = Vector2(1.0, 1.0)
		current_scene.get_node("Camera2D").position = current_scene.initial_camera_pos
		self.position = Vector2(get_viewport().get_visible_rect().size.x, 0)
		
	if get_tree().paused == true:
		get_tree().paused = false
	global.transition_animation("res://main_menu.tscn")
	self.visible = false
	


func _on_resume_pressed() -> void:
	if current_scene.name == "level":
		current_scene.rider_has_been_ejected = false
		current_scene.get_node("Camera2D").zoom = Vector2(1.0, 1.0)
		current_scene.get_node("Camera2D").position = current_scene.initial_camera_pos
		self.position = Vector2(get_viewport().get_visible_rect().size.x, 0)
		current_scene.get_node("ui").visible = true
	if global.health >0:
		if get_tree().paused == true:
			get_tree().paused = false
		queue_free()


func _on_main_menu_2_pressed() -> void:
	pass # Replace with function body.

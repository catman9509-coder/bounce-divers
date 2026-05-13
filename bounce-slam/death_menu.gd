extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_again_pressed() -> void:
	if get_tree().paused == true:
		get_tree().paused = false
	get_tree().change_scene_to_file("res://level.tscn")
	global.start_game = false
	global.health = 2
		


func _on_main_menu_pressed() -> void:
	if get_tree().paused == true:
		get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_resume_pressed() -> void:
	if global.health >0:
		if get_tree().paused == true:
			get_tree().paused = false
		queue_free()


func _on_main_menu_2_pressed() -> void:
	pass # Replace with function body.

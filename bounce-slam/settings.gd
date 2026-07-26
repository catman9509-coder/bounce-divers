extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_death_menu_switch_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		global.death_screen = false
	else:
		global.death_screen = true
	


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")

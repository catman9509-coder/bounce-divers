extends Node2D
var frame_size
var fill = Fill_screen.new()
var selected_item
var current_scene
var hidden_content = []
var paused = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hidden_content = [$shop_button, $play_button, $strg_button, $equip_buy_button, $current_balance ]
	hide_content()
	current_scene = get_tree().current_scene
	#var image_size = $Sprite2D.texture.get_size() * $Sprite2D.scale
	fill.image = $Sprite2D
	fill.fix_size()
	$Sprite2D.get_rect().size.x = global.actuall_screen.x#screen_size.x
	$Sprite2D.get_rect().size.y = global.actuall_screen.y
	print("buy or equip button size -->", $equip_buy_button.shape.size)
func _process(delta: float) -> void:
	$current_balance.text = "CRDTS : " +  str(global.stored_coins)
	if current_scene.name == "main_menu":
		$item_description.text = current_scene.selected_item["description"]
func play_animation(animation : String):
	$AnimationPlayer.play(animation)


func _on_shop_button_pressed() -> void:
	current_scene.get_node("Camera2D/CanvasLayer/Control2/shop").emit_signal("button_down")


func _on_shop_button_released() -> void:
	current_scene.get_node("Camera2D/CanvasLayer/Control2/shop").emit_signal("button_up")


func _on_play_button_pressed() -> void:
	current_scene.get_node("Camera2D/CanvasLayer/Control2/play").emit_signal("button_down")


func _on_play_button_released() -> void:
	current_scene.get_node("Camera2D/CanvasLayer/Control2/play").emit_signal("button_up")

func _on_strg_button_pressed() -> void:
	current_scene.get_node("Camera2D/CanvasLayer/Control2/owned_items").emit_signal("button_down")


func _on_strg_button_released() -> void:
	current_scene.get_node("Camera2D/CanvasLayer/Control2/owned_items").emit_signal("button_up")

func _on_equip_buy_button_pressed() -> void:
	current_scene.get_node("Camera2D/CanvasLayer/info_display/select_button").emit_signal("pressed")
func change_frame(selected_frame : int):
	$Sprite2D.frame = selected_frame
func reveal_content():
	for item in hidden_content:
		item.visible = true
func hide_content():
	for item in hidden_content:
		item.visible = false
	


func _on_equip_buy_button_released() -> void:
	pass # Replace with function body.


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "appear":
		reveal_content()
		if current_scene.name == "main_menu":
			if current_scene.window_opened == "strg":
				#current_scene.get_node("owned_items").get_node("Control").global_position = $sub_window_space.position
				current_scene.get_node("owned_items").visible = true
				current_scene.get_node("shop").visible = false
				
			if current_scene.window_opened == "shop":
				current_scene.get_node("owned_items").visible = false
				current_scene.get_node("shop").visible = true
		$AnimationPlayer.pause()
		paused = true
	else:
		paused = false
		

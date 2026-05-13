extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://level.tscn")
	global.start_game = false
	global.health = 2


func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://shop.tscn")


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://settings.tscn")


func _on_owned_items_pressed() -> void:
	get_tree().change_scene_to_file("res://owned_items.tscn")

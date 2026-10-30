extends Node2D
var scene : String
var fill = Fill_screen.new()
var current_scene
func _ready() -> void:
	current_scene = get_tree().current_scene
	fill.image = $Sprite2D
	print(fill.image.get_rect().size)
	fill.fix_size()
	print(fill.image.get_rect().size)
	print(global.actuall_screen)
	print(self.name)


	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "normal_transition":
		get_tree().change_scene_to_file(scene)
		queue_free()
	if anim_name == "scene_changed":
		queue_free()

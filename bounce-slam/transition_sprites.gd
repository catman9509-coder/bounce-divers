extends Node2D
var scene : String

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name:
		get_tree().change_scene_to_file(scene)
		queue_free()

extends Node2D
var msg : String
var anim : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_text(msg)
	play_animation(anim)



	
func label_text (msg ):
	$TextureRect/Label.text = msg
func play_animation(anim):
	$AnimationPlayer.play(anim)
	
	

	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == anim:
		queue_free()

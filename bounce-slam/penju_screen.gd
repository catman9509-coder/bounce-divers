extends Node2D
var fade : PackedScene = preload("res://death_background.tscn")
var penju_animation_played = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade_in()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_animated_sprite_2d_animation_finished() -> void:
	penju_animation_played = true
	fade_out()
	
func fade_in():
	var transition = fade.instantiate()
	transition.get_node("AnimationPlayer").animation_finished.connect(func (anim_name): transition_animation_finished("fade_out"))
	add_child(transition)
	transition.get_node("AnimationPlayer").play_backwards("fade_out")
func fade_out():
	var transition = fade.instantiate()
	transition.get_node("AnimationPlayer").animation_finished.connect(func (anim_name): transition_animation_finished("fade_out"))
	add_child(transition)
	transition.get_node("AnimationPlayer").play("fade_out")
func transition_animation_finished(animation : String):
	if animation == "fade_out" and penju_animation_played == false:
		$Node2D/AnimatedSprite2D.play("appear")

	else:

		get_tree().change_scene_to_file("res://title_screen.tscn")
		
		

extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("fade in")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Node2D.rotation += 0.01
func fadeout():
	$AnimationPlayer.play("fade out")



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade out":
		self.queue_free()

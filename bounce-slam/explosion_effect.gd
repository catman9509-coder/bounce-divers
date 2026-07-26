extends Node2D
var subject : String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	explode(subject)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func explode(subject):
	$Node2D/AnimatedSprite2D.animation = subject
	
	$AnimationPlayer.play(subject)
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == subject:
		self.queue_free()

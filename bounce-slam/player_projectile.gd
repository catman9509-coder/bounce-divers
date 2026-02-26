extends RigidBody2D
var speed

var mode : String
var modes = ["soap_bomb", "soap_bar"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match mode:
		"soap_bomb":
			$Node2D/AnimatedSprite2D.play("soap_bomb")
		"soap_bar":
			$Node2D/AnimatedSprite2D.play("soap_bar")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global.enemy_up:
		position.y -= delta * 80
	if global.enemy_down:
		position.y += delta * 80
	else:
		position.y += delta * 80

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		match mode:
			"soap_bar":
					body.queue_free()
					queue_free()
			"soap_bomb":
				$Node2D/AnimatedSprite2D.play("explode")
				$AnimationPlayer.play("explode")
			_:
				pass
	if body.has_method("crate"):
		body.spawn_upgrade = true
	if body.has_method("upgrade"):
		print(body.name)
		global.upgrade(body.name)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "explode":
		for body in $detection_area.get_overlapping_bodies():
			body.queue_free()
		
		queue_free()
		

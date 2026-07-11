extends StaticBody2D
var cleaned 
var being_cleaned
var infested
var options = [true, false]
var collision_effect : PackedScene = load("res://collision_effect.tscn")
var first_collision = true
var can_shift = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cleaned = options[randi() % options.size()]
	if cleaned == false:
		infested = not cleaned


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for body in $detection_area.get_overlapping_bodies():
		if body.has_method("player"):
			if first_collision:
				
				collide(body)
				first_collision = false
			if cleaned == false:
				$AnimatedSprite2D.play("being_cleaned")
				infested = false
		if can_shift:
			if body.name.contains("barrier"):
				if body.position.y < self.position.y:
					self.position.y += body.get_node("detection_area/CollisionShape2D").shape.size.y/2
					can_shift = false
		
	if infested:
		$AnimatedSprite2D.play("infested")
	if cleaned:
		$AnimatedSprite2D.play("clean")
	


func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "being_cleaned":
		cleaned = true
		global.pay_for_cleaning(randi_range(1, 5))
		print(global.gathered_coins)
func collide(target):
	var effect = collision_effect.instantiate()
	if target.position.x > position.x:
		effect.position = Vector2( self.global_position.x + $CollisionShape2D.shape.size.x/2 , target.global_position.y)
	else:
		effect.position = Vector2( self.global_position.x - $CollisionShape2D.shape.size.x/2 , target.global_position.y)
	get_parent().add_child(effect)
	if cleaned == false:
		effect.get_node("Node2D/AnimatedSprite2D").play("infested")
		effect.get_node("AnimationPlayer").play("infested_effect")
	else:
		effect.get_node("Node2D/AnimatedSprite2D").play("clean")
		effect.get_node("AnimationPlayer").play("clean_effect")
		
		


func _on_detection_area_body_exited(body: Node2D) -> void:
	first_collision = true

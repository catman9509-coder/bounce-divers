extends CharacterBody2D
var aggravated = false
var speed = 80
var can_attack
var special_action = false
func _physics_process(delta: float) -> void:
	#death
	
	for body in $detection_area.get_overlapping_bodies():
		if body.has_method("player"):
			aggravated = true
			attack(body)
		else:
			can_attack = false
			aggravated = false

	move_and_slide()
func enemy():
	pass
func attack(target):
	if aggravated:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		#rotation_degrees = target.global_position.x - global_position.x
		look_at(target.global_position)
		move_and_slide()
	else:
		pass


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("player") and aggravated == true:
		global.attacked(1.0)

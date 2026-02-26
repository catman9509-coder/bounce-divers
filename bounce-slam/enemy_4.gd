extends CharacterBody2D
var special_action = false
var can_attack = true
var attacking = false


func _physics_process(delta: float) -> void:
	for body in $detection_area.get_overlapping_bodies():
		if body.has_method("player"):
			if can_attack:
				special_action = true
				attack(body)
				can_attack = false
	if attacking:
		$Node2D/head/attack_area/CollisionShape2D.disabled = false
	else:
		$Node2D/head/attack_area/CollisionShape2D.disabled = true
		

	move_and_slide()
func enemy():
	pass
func attack(target):
	if special_action:
		attacking = true
		velocity = Vector2.ZERO
		if position.y >= target.position.y:
			$AnimationPlayer.play("attack_animation")
	var cooldown = Timer.new()
	cooldown.wait_time = 3.0
	cooldown.one_shot = true
	cooldown.timeout.connect(cooldown_timeout)
	add_child(cooldown)
	cooldown.start()
func cooldown_timeout():
	
	can_attack = true

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		if attacking:
			print("player attacked")
			global.attacked(1.0)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack_animation":
		attacking = false
		special_action = false
		$AnimationPlayer.play("return_animation")
		
	if anim_name == "return_animation":
		pass

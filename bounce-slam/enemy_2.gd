extends CharacterBody2D
var aggravated = false
var speed = 80
var can_attack
var special_action = false
var can_infect = randf_range(true, false)
var type = Spawns.new()
func _ready() -> void:
	type.can_travel = true
	$hands.play("default")
	$hands/body.play("default")
func _physics_process(delta: float) -> void:
	if global.game_started:
		type.travel(self, delta)
		if special_action:
			type.can_travel = false
		else:
			type.can_travel = true
		for body in $detection_area.get_overlapping_bodies():
			if body.has_method("player"):
				aggravated = true
				attack(body)
			else:
				can_attack = false
				aggravated = false
			if body.has_method("barrier") and can_infect:
				if body.infested == true and body.cleaned == not body.infested and body.can_create_enemy == true:
					aggravated = true
					attack(body)

		move_and_slide()
func enemy():
	pass
func attack(target):
	
	if aggravated:
		$hands.play("attack")
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		#rotation_degrees = target.global_position.x - global_position.x
		$hands.rotation = PI/2
		look_at(target.global_position)
		move_and_slide()
	
		


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("player") and aggravated == true:
		global.attacked(1.0)

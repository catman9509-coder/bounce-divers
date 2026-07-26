extends CharacterBody2D
var special_action = false
var can_attack = true
var attacking = false
var hori_speed = 40
var can_infect = randf_range(true, false)
var type = Spawns.new()

func _ready():
	type.can_travel = true
	
	$attack_area/CollisionShape2D.disabled = true
func _physics_process(delta: float) -> void:
	if global.game_started:
		type.travel(self, delta)
		if special_action:
			type.can_travel = false
		else:
			type.can_travel = true
		for body in $detection_area.get_overlapping_bodies():
			if body.has_method("player"):
				if can_attack:
					special_action = true
					attack(body)
					can_attack = false
			if body.has_method("barrier") and can_infect:
				if body.cleaned == true and body.infested == not body.cleaned and body.can_create_enemy == true:
					if body.global_position.x > global_position.x:
						global_position.x += hori_speed 
						if global_position.x >= body.global_position.x - $detection_area/CollisionShape2D.shape.size.x/2:
							body.cleaned = false
							body.infested = not body.cleaned
					if body.global_position.x < global_position.x:
						global_position.x -= hori_speed 
						if global_position.x <= body.global_position.x + $detection_area/CollisionShape2D.shape.size.x/2:
							body.cleaned = false
							body.infested = not body.cleaned
							
			

		move_and_slide()
func enemy():
	pass
func attack(target):
	if special_action:
		attacking = true
		velocity = Vector2.ZERO
		if position.y >= target.position.y:
			$body.play("attack")
			$AnimationPlayer.play("attack")
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
	if anim_name == "attack":
		print("animation finished")
		attacking = false
		special_action = false
		$body.play("default")
		
	if anim_name == "return_animation":
		pass


func _on_body_animation_finished() -> void:
	if $body.animation == "attack":
		$body.animation = "default"
		special_action = false
		

extends StaticBody2D
var projectile : PackedScene = load("res://projectile.tscn")
var special_action = false
var can_attack = true
var attacking = false
var shot_speed = 200
var velocity
var can_infect = randf_range(true, false)
var type = Spawns.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	type.can_travel = true
	$Node2D/body.play("default")
	$Node2D/barrel.play("default")

func enemy():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global.game_started:
		type.travel(self, delta)
		if special_action:
			type.can_travel = false
		else:
			type.can_travel = true
		
		for body in $detection_area.get_overlapping_bodies():
			if body.has_method("player"):
				
				look_at(body.global_position)
				$Node2D.rotation = PI/2
				if can_attack:
					
					special_action = true
					shoot(body)
					can_attack = false
			if body.has_method("barrier") and can_infect:
				if body.cleaned == true and body.infested == not body.cleaned and body.can_create_enemy == true:
					$Node2D.rotation = PI/2
					if can_attack:
						special_action = true
						shoot(body)
						can_attack = false
					
			
				
				
func shoot(target):
	$Node2D/barrel.play("attack")
	if special_action:
		velocity = Vector2.ZERO
		var shot = projectile.instantiate()
		shot.position = $firing_point.global_position
		var shot_direction = (target.global_position - $firing_point.global_position).normalized()
		shot.linear_velocity = shot_direction * shot_speed
		shot.gravity_scale = 0
		get_parent().add_child(shot)
	var cooldown = Timer.new()
	cooldown.wait_time = 4.0
	cooldown.one_shot = true
	cooldown.timeout.connect(cooldown_timeout)
	add_child(cooldown)
	cooldown.start()
	var special_action_timer = Timer.new()
	special_action_timer.wait_time = 1.0
	special_action_timer.one_shot = true
	special_action_timer.timeout.connect(special_action_timeout)
	add_child(special_action_timer)
	special_action_timer.start()
	
func special_action_timeout():
	special_action = false
	$Node2D/barrel.play("default")

	
func cooldown_timeout():
	can_attack = true
	

	
	

extends StaticBody2D
var cleaned 
var being_cleaned
var infested
var options = [true, false]
var enemy_1 : PackedScene = load("res://enemy_1.tscn")
var enemy_2 : PackedScene = load("res://enemy_2.tscn")
var enemy_3 : PackedScene = load("res://enemy_3.tscn")
var enemy_4 : PackedScene = load("res://enemy_4.tscn")
var possible_enemies = [enemy_1, enemy_2, enemy_3, enemy_4]
var collision_effect : PackedScene = load("res://collision_effect.tscn")
var first_collision = true
var can_shift = true
var barrier_index
var hostile
var can_create_enemy = true
var found_group = false
var starting_spawn_point
var barrier_speed = 400 / global.difficulty


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cleaned = options[randi() % options.size()]
	if cleaned == false:
		infested = not cleaned


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global.game_started:
		move(delta)
	if found_group == false:
		find_group()
	
	for body in $detection_area.get_overlapping_bodies():
		if body.has_method("enemy") and body.can_infect:
			collide(body)
			cleaned = false
			infested = not cleaned 
			can_create_enemy = true
			body.queue_free()
		if body.has_method("player"):
			if first_collision:
				collide(body)
				first_collision = false
			if cleaned == false:
				$AnimatedSprite2D.play("being_cleaned")
				infested = false
		if can_shift:
			if body.has_method("barrier"): #and body != self:
					
				var distance = randi_range(10, 300)
				if self in global.left_barriers:
					barrier_index = global.left_barriers.find(self)
					var body_index = global.left_barriers.find(body)
					
					if body_index > barrier_index:
						if body == self or body.global_position == self.global_position:
							body.queue_free()
						else:
							if body.infested == true and self.infested == true:
								body.can_create_enemy = false
							if self.cleaned == true:
								body.cleaned = true
								
							
							body.global_position.y += body.get_node("CollisionShape2D").shape.size.y + distance
						
				if self in global.right_barriers:
					barrier_index = global.right_barriers.find(self)
					var body_index = global.right_barriers.find(body)
					if body_index > barrier_index:
						if body == self or body.global_position == self.global_position:
							body.queue_free()
						else:
							if body.infested == true and self.infested == true:
								body.can_create_enemy = false
							if self.cleaned == true:
								body.cleaned = true
							body.global_position.y += body.get_node("CollisionShape2D").shape.size.y + distance
		if infested and can_create_enemy and found_group:
			spawn_enemy()
			
	if infested:
		$AnimatedSprite2D.play("infested")
	if cleaned:
		$AnimatedSprite2D.play("clean")
	

func barrier():
	pass
func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "being_cleaned":
		cleaned = true
		global.pay_for_cleaning(randi_range(1, 5))

		print(global.gathered_coins)
func collide(target):
	var effect = collision_effect.instantiate()
	if target.position.x > position.x:
		effect.position = Vector2( self.global_position.x + $CollisionShape2D.shape.size.x/1.1 , target.global_position.y)
		effect.rotation = PI/2
	else:
		effect.rotation = -PI/2
		effect.position = Vector2( self.global_position.x - $CollisionShape2D.shape.size.x/1.1 , target.global_position.y)
	get_parent().add_child(effect)
	if cleaned == false:
		effect.get_node("Node2D/AnimatedSprite2D").play("infested")
		effect.get_node("AnimationPlayer").play("infested_effect")
	else:
		effect.get_node("Node2D/AnimatedSprite2D").play("clean")
		effect.get_node("AnimationPlayer").play("clean_effect")
	if target.has_method("enemy"):
		if infested == false:
			infested = true
			target.queue_free()
		else:
			target.queue_free()
			
		
		


func _on_detection_area_body_exited(body: Node2D) -> void:
	first_collision = true
func spawn_enemy():
	var spawn_delay = Timer.new()
	spawn_delay.wait_time = randi_range(1, 3)
	spawn_delay.one_shot = true
	
	spawn_delay.timeout.connect(spawn_enemy_timeout)
	add_child(spawn_delay)
	spawn_delay.start()
	can_create_enemy = false

	
func spawn_enemy_timeout():
	if global.spawned_objects.size() < 8:
		var enemy = possible_enemies[randi() % possible_enemies.size()].instantiate()
		global.spawned_objects.append(enemy)
		enemy.can_infect = false
		if self in global.left_barriers:
			enemy.global_position = Vector2(starting_spawn_point.x , starting_spawn_point.y)
		if self in global.right_barriers:
			enemy.global_position = Vector2(starting_spawn_point.x , starting_spawn_point.y)
		get_parent().add_child(enemy)
func find_group():
	if self in global.current_barriers:
		if self in global.left_barriers:
			starting_spawn_point = Vector2(global_position.x + $detection_area/CollisionShape2D.shape.size.x/2, global_position.y)
			found_group = true
		if self in global.right_barriers:
			starting_spawn_point = Vector2(global_position.x - $detection_area/CollisionShape2D.shape.size.x/2, global_position.y)
			found_group = true
func move(delta):
	position.y -= barrier_speed * delta
	

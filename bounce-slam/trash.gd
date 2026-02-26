extends CharacterBody2D
var rotation_rate : int
var animations = ["barrel", "box", "food"]
var fire = false
var attached = false
func _ready() -> void:
	rotation_rate = randi_range(-3, 3)
	$AnimatedSprite2D.play(animations.pick_random())
	
	


func _physics_process(delta: float) -> void:
	rotation += rotation_rate * delta
	for body in $detection_area.get_overlapping_bodies():
		if body.has_method("player") and global.base_state == "magnet":
			
			if fire == false:
				if position.x <= body.position.x+10 and position.x >= body.position.x-10:
					position = body.position
				if position.y <= body.position.y+10 and position.y >= body.position.y-10:
					position = body.position
					
				else:
					$CollisionShape2D.disabled = true
					position -= ( position - body.position).normalized()
				
				
					
	if fire == true:
		
		position.y += 500 * delta
		var life_timer = Timer.new()
		life_timer.one_shot = true
		life_timer.wait_time = 2.0
		life_timer.timeout.connect(life_timer_timeout)
		add_child(life_timer)
		life_timer.start()
func life_timer_timeout():
	queue_free()
	
func object():
	pass
		
			
	
func magnetic():
	pass


func _on_attack_area_body_entered(body: Node2D) -> void:
	if fire == true:
		if body.has_method("enemy"):
			body.queue_free()
		if body.has_method("crate"):
			body.spawn_upgrade = true
		if body.has_method("base_crate"):
			body.spawn_base_upgrade = true
		
		if body.has_method("upgrade"):
			print(body.name)
			global.upgrade(body.name)

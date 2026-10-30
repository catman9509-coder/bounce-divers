extends CharacterBody2D
var collision = false
var rotation_rate = randi_range(-3, 3)
var can_squish = false
var squished = false

func _ready():
	$CollisionShape2D/AnimatedSprite2D.play("appear")
	
func _physics_process(delta: float) -> void:
	if position.x >= get_viewport().get_visible_rect().size.x:
		velocity.x = -100
	if position.x <= 0:
		velocity.x = 100
	if position.y >= get_viewport().get_visible_rect().size.y:
		velocity.y = -100
	if position.y <= 0:
		velocity.y = 100
	if squished == true:
		scale = Vector2(1.0, 1.0)
	rotation += rotation_rate * delta
	move_and_slide()
	if get_tree().current_scene.name == "level":
		if get_tree().current_scene.rider_has_been_ejected == false:
			self.visible = false
		





func _on_detection_area_body_entered(body: Node2D) -> void:
	if "background" not in body.name:
		rotation_rate = randi_range(-3, 3)
		var x_squish = 0.7
		var y_squish = 0.7
		if body.position.x > self.position.x:
			velocity.x = -60
		else:
			velocity.x = 60
		if body.position.y > self.position.y:
			velocity.y = -60
		else:
			body.position.y = 60
		if can_squish:
			squish(x_squish, y_squish)
		can_squish = false
func squish(x, y):
		
	while scale != Vector2(x, y):
		await get_tree().process_frame
		if scale.x > x:
			scale.x -= 0.1
		if scale.x < x:
			scale.x += 0.1
		if scale.y > y:
			scale.y -= 0.1
		if scale.y < y:
			scale.y += 0.1
	squished = true



func _on_detection_area_body_exited(body: Node2D) -> void:
	if squished:
		can_squish = true
		squished = false

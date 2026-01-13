extends CharacterBody2D

var possible_directions = ["left", "right"]
const left_speed = -100.0
const right_speed = 100.0
var possible_speeds = [left_speed, right_speed]
const JUMP_VELOCITY = -400.0
var start_motion = false
var hori_direction
var health
# take track of speed
var last_speed 

func _ready():
	pass
func player():
	pass
func _physics_process(delta: float) -> void:
	
	health = global.health
	#death
	if health <= 0:
		get_tree().reload_current_scene()
		global.start_game = false
		global.health = 2
# start motion to begin game
	if start_motion:
		hori_direction = possible_directions[randi() % possible_directions.size()]
		start_motion = false
	directional_speed(hori_direction)
	
		
	# Add the gravity.
	#if not is_on_floor():
	#	velocity += get_gravity() * delta
	# Handle jump.
	if global.start_game == false:
		if Input.is_action_just_pressed("ui_accept"):
			start_motion = true
			global.start_game = true
		
	if Input.is_action_pressed("ui_down"):
		position.y += 5
	if Input.is_action_pressed("ui_up"):
		position.y -= 5
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	move_and_slide()
	var collision = move_and_collide(velocity * delta)
#	for body in $detection_area.get_overlapping_bodies():
#		if "left" in body.name:
#			velocity.x = right_speed
#			hori_direction = "right"
#		if "right" in body.name:
#			velocity.x = left_speed
#			hori_direction = "left"
#		if "border" in body.name:
#			if "up" in body.name:
#				velocity.y += 300
#			if "down" in body.name:
#				velocity.y -= 300
#			else:
#				direction = possible_directions[randi() % possible_directions.size()]
	if collision:
		var collided_body = collision.get_collider().global_position
		if collided_body.x > position.x:
			hori_direction = "left"
		if collided_body.x < position.x:
			hori_direction = "right"
	for body in $detection_area.get_overlapping_bodies():
		if "left" in body.name:
			velocity.x = right_speed
			hori_direction = "right"
		if "right" in body.name:
			velocity.x = left_speed
			hori_direction = "left"
			
			
				
func directional_speed(direction):
	if direction == "right":
		velocity.x = right_speed
		last_speed = right_speed
	if direction == "left":
		velocity.x = left_speed
		last_speed = left_speed
	else:
		if velocity.x == 0 and global.start_game == true:
			velocity.x = last_speed
		

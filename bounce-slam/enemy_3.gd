extends CharacterBody2D
# attack variable
var attacking = false
var can_attack = true
var special_action = false
#other variables
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready() -> void:
	pass
func _physics_process(delta: float) -> void:
	for body in $detection_area.get_overlapping_bodies():
		if body.has_method("player"):
			$eyes.look_at(body.global_position)
			if can_attack:
				special_action = true
				attack()
				can_attack = false
	if special_action == false:
		normalize()
	for body in $attack_area.get_overlapping_bodies():
		if body.has_method("player"):
			if attacking:
				global.attacked(1.0)
	move_and_slide()
func attack():
	if special_action:
		attacking = true
		velocity = Vector2.ZERO
		$body.play("attack")
		for CollisionShape2D in $attack_area.get_children():
			CollisionShape2D.disabled = false
		var cooldown_timer = Timer.new()
		cooldown_timer.one_shot = true
		cooldown_timer.wait_time = 3.0
		cooldown_timer.timeout.connect(cooldown_timeout)
		add_child(cooldown_timer)
		cooldown_timer.start()
func cooldown_timeout():
	can_attack = true

func normalize():
		$body.play("default")
		for CollisionShape2D in $attack_area.get_children():
			CollisionShape2D.disabled = true


func _on_body_animation_finished() -> void:
	if $body.animation == "attack":
		attacking = false
		special_action = false

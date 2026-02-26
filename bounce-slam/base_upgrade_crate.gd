extends CharacterBody2D
var collision_effect : PackedScene = load("res://collision_effect.tscn")
var rocket_burst_upgrade : PackedScene = load("res://rocket_burst.tscn")
var magnet_upgrade : PackedScene = load("res://magnet_upgrade.tscn")
var base_upgrade : PackedScene = load("res://base_upgrade.tscn")
var rotation_rate = randi_range(-3, 3)
var possible_upgrades = [rocket_burst_upgrade, magnet_upgrade, base_upgrade]
var spawn_base_upgrade = false
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func ready():
	pass
	
func _physics_process(delta: float) -> void:
	rotation += rotation_rate * delta
	move_and_slide()
	if spawn_base_upgrade == true:
		self.queue_free()
		var upgrade = possible_upgrades[randi()%possible_upgrades.size()].instantiate()
		upgrade.global_position = self.global_position
		get_parent().add_child(upgrade)
		spawn_base_upgrade = false
		
func base_crate():
	pass

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		var collision = collision_effect.instantiate()
		collision.global_position = body.global_position
		collision.get_node("AnimationPlayer").play("clean_effect")
		if body.position.y > self.position.y +50:
			collision.global_rotation = 90
		if body.position.y < self.position.y - 50:
			collision.global_rotation = -90
		get_parent().add_child(collision)
	if "player_attack" in body.name:
		spawn_base_upgrade = true

		
		

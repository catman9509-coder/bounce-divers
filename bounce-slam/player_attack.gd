extends Node2D
var death_effect : PackedScene = load("res://explosion_effect.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#for body in $attack_area.get_overlapping_bodies():
	#	print("enemy detected")
	#	if body.has_method("enemy"):
	#		print("enemy detected")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "base_attack":
		self.queue_free()
func _on_attack_area_body_entered(body: Node2D) -> void:
	var explosion_effect = death_effect.instantiate()
	explosion_effect.subject = "enemy_1" 
	if body.has_method("enemy"):
		explosion_effect.position = body.global_position
		if get_parent().global_position.x > body.global_position.x:
			get_parent().hori_direction = "right"
		if get_parent().global_position.x < body.global_position.x:
			get_parent().hori_direction = "left"
		global.exterminations += 1
		get_parent().get_parent().add_child(explosion_effect)
		body.queue_free()
	if body.has_method("crate"):
		body.spawn_upgrade = true
	if body.has_method("base_crate"):
		body.spawn_base_upgrade = true
		
	
	if body.has_method("upgrade"):
		print(body.name)
		global.upgrade(body.name)
		

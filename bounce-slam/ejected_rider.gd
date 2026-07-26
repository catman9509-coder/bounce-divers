extends CharacterBody2D

var rotation_rate = randi_range(-3, 3)


func _physics_process(delta: float) -> void:
	rotation += rotation_rate * delta
	move_and_slide()

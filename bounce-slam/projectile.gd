extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var linear_velocity


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		global.attacked(1.0)
		queue_free()
	if body.has_method("barrier"):
		if body.cleaned == true and body.infested == not body.cleaned:
			body.cleaned = false
			body.infested = not body.cleaned

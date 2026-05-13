extends StaticBody2D
var rotation_rate = randi_range(-3, 3)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation += rotation_rate
	


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		body.can_horizontal_shift = true
		self.queue_free()

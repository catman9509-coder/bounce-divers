extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
func upgrade():
	pass

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		self.scale.x += 0.1
		self.scale.y += 0.1
		var deletion_delay = Timer.new()
		deletion_delay.wait_time = 1.0
		deletion_delay.one_shot = true
		deletion_delay.timeout.connect(deletion_delay_timeout)
		add_child(deletion_delay)
		deletion_delay.start()
		global.upgrade(self.name)
		
func deletion_delay_timeout():
	queue_free()

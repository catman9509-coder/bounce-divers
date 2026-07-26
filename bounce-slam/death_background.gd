extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "rocket_burst":
		self.queue_free()
	if anim_name == "fade_out":
		self.queue_free()
	if anim_name == "normal":
		get_tree().paused = true
		var transition_timer = Timer.new()
		transition_timer.wait_time = 0.5
		transition_timer.one_shot = true
		transition_timer.timeout.connect(transition_timeout)
		add_child(transition_timer)
		transition_timer.start()
func transition_timeout():
	self.queue_free()

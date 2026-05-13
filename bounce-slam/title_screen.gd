extends CanvasLayer
var fade_out : PackedScene = preload("res://death_background.tscn")
var can_transition = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	var transition_timer = Timer.new()
	transition_timer.wait_time = 1.0
	transition_timer.one_shot = true
	transition_timer.timeout.connect(transition_timeout)
	add_child(transition_timer)
	var transition = fade_out.instantiate()
	if can_transition:
		if event is InputEventMouseButton and event.pressed:
			transition_timer.start()
			add_child(transition)
			transition.get_node("AnimationPlayer").play("fade_out")
			can_transition = false
		if event is InputEventScreenTouch and event.pressed:
			transition_timer.start()
			add_child(transition)
			transition.get_node("AnimationPlayer").play("fade_out")
			can_transition = false
		
func transition_timeout():
	print("done")
	get_tree().change_scene_to_file("res://main_menu.tscn")
	
	

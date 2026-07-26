extends Node2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$player.can_move = true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for layer in $backgrounds.get_children():
		var speed = 10
		if layer.name.contains("layer"):
			speed = 100
		layer.position.y -= speed * delta
		if layer.get_node("lower_point").global_position.y <=0:
			layer.position = Vector2(0,0)
			
		
	

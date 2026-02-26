extends ParallaxBackground
var speed := Vector2(0, 50)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scroll_base_offset.y += 50 * delta
	scroll_limit_begin
	

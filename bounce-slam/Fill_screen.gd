extends Node

class_name Fill_screen
var image : Sprite2D
var animated_image : AnimatedSprite2D
func fix_size():
	image.get_rect().size.x = global.actuall_screen.x#screen_size.x
	image.get_rect().size.y = global.actuall_screen.y
func fix_scale_size():
	var frame_size = image.get_rect().size
	var x_difference = global.actuall_screen.x/frame_size.x
	var y_difference = global.actuall_screen.y/frame_size.y
	var x_scale_factor = 1 - x_difference  
	var y_scale_factor = 1 - y_difference  
	var scale_factor = Vector2(x_scale_factor, y_scale_factor)
	image.scale = scale_factor
	#image.position = Vector2(global.actuall_screen.x/2, global.actuall_screen.y/2)
	print(global.actuall_screen)
	print(frame_size)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

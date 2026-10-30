extends Node
class_name Sub_window
var window_rect : Control
var target_size : Vector2

var scale_factor

func fix_anchors():
	window_rect.anchor_left = 0
	window_rect.anchor_right = 1
	window_rect.anchor_top = 0
	window_rect.anchor_bottom = 1
	window_rect.offset_left = 0
	window_rect.offset_top = 0
	window_rect.offset_right = 0
	window_rect.offset_bottom = 0
	#window_rect.size_flags_horizontal = SIZE_EXPAND
	#window_rect.size_flags_vertical = SIZE_EXPAND
	window_rect.custom_minimum_size = Vector2(0, 0)
func fix_size():
	var initial_size = window_rect.size
	window_rect.custom_maximum_size = target_size
	var y_difference = target_size.y/initial_size.y
	var x_difference = target_size.x/initial_size.x
	var y_scale_factor = 1 - y_difference
	var x_scale_factor = 1 - x_difference
	scale_factor = Vector2(x_scale_factor, y_scale_factor)
	window_rect.scale = scale_factor
	#scale_factor = Vector2(x_scale_factor, y_scale_factor)
	

	print("sizefixed")
func fix_children_size(child):
	print("vboxes initial_size" , child.size)
	#child.custom_minimum_size = Vector2(target_size.x, window_rect.size.y)
	child.custom_maximum_size = Vector2(target_size.x, target_size.y)
	#child.set_size(Vector2(target_size.x, window_rect.size.y))
	child.scale = scale_factor
	for item in child.get_children():
		item.scale = scale_factor
		for other_item in item.get_children():
			other_item.scale = scale_factor
			print(scale_factor)
	print("vboxes size - " , child.size)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

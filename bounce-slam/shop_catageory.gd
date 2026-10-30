extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	print(self.get_rect().size)
	pass
#	anchor_left = 0
#	anchor_right = 1
#	anchor_top = 0
#	anchor_bottom = 1
#	offset_left = 0
#	offset_top = 0
#	offset_right = 0
#	offset_bottom = 0
#	size_flags_horizontal = SIZE_EXPAND
#	size_flags_vertical = SIZE_EXPAND
#	custom_minimum_size = Vector2(0, 0)###
	#self.custom_maximum_size = get_parent().get_size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends StaticBody2D
var vehicle_skins = ["default"]
var vehicle : String
var lane : String
var type = Spawns.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name = "vehicle"
	vehicle = vehicle_skins[randi()% vehicle_skins.size()]
	$AnimatedSprite2D.play(vehicle)
	for body in $detection_area.get_overlapping_bodies():
		if body.has_method("player"):
			if body.global_position.y > global_position.y + $CollisionShape2D.shape.y/2:
				$collisionShape2D.disabled = true
			if body.global_position.y < global_position.y - $CollisionShape2D.shape.y/2:
				$collisionShape2D.disabled = true
		else:
			$CollisionShape2D.disabled = true
func _process(delta: float) -> void:
	if lane:
		type.vehicle_travel(self, delta, lane)
func vehicle_object():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.

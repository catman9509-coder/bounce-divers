extends Node

class_name Spawns
var enemy : bool
var can_travel : bool
var item : bool
var default_travel_speed = -150
var vehicle_travel_speed = -200
func travel(node, delta):
	if global.game_started:
		if can_travel and not node.has_method("magnetic" ):
			node.position.y += default_travel_speed * delta
		else:
			if node.has_method("magnetic"):
				if node.fire == false:
					node.position.y += default_travel_speed * delta	
func vehicle_travel(node, delta, lane):
	if lane == "left":
		node.position.y -= vehicle_travel_speed * delta
	else:
		node.position.y += vehicle_travel_speed * delta
		

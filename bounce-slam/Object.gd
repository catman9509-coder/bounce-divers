extends Node

class_name object
var enemy : bool
var can_travel : bool
var item : bool
var default_travel_speed = -150
var vehicle_travel_speed = -200
func travel(node, delta):
	if can_travel:
		node.position.y += default_travel_speed * delta
func vehicle_travel(node, delta, lane):
	if lane == "left":
		node.position.y -= vehicle_travel_speed * delta
	else:
		node.position.y += vehicle_travel_speed * delta
		

extends Node
class_name Barrier
var can_move
var barrier_speed = -40

func move(node, delta):
	if can_move:
		node.position.y += barrier_speed * delta

	

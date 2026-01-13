extends Node
#player variables
var health
var can_be_attacked = true
var immunity_duration = 1.0
#game_variables
var start_game = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func attacked(lost_health):
	if can_be_attacked:
		health -= lost_health
		immunity_duration = 1.0
		immunity_time(immunity_duration)
func immunity_time(immunity_duration):
	can_be_attacked = false
	var immunity_timer = Timer.new()
	immunity_timer.wait_time = immunity_duration
	immunity_timer.one_shot = true
	immunity_timer.timeout.connect(immunity_timeout)
	add_child(immunity_timer)
	immunity_timer.start()
func immunity_timeout():
	can_be_attacked = true
		
	
func death():
	pass

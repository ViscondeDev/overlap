class_name Echo
extends PathFollow2D

var player_path:PlayerPath
var point:int = 0

func _process(delta: float) -> void:
	if point == player_path.curve.point_count - player_path.updates_per_second : queue_free()

	var distance = (global_position - player_path.curve.get_point_position(point)).length()
	if distance < 20:return

	var smooth_movement = distance * player_path.updates_per_second  * delta
	progress += smooth_movement


func follow_player():
	point += 1

class_name Echo
extends PathFollow2D

var player_path: PlayerPath
var next_path_point: int = 0

func _process(delta: float) -> void:
	var next_position: Vector2 = player_path.curve.get_point_position(next_path_point)
	var distance = (global_position - next_position).length()
	if distance < 20: return

	var smooth_movement = distance * player_path.updates_per_second  * delta
	progress += smooth_movement


func increment_point() -> void:
	next_path_point += 1

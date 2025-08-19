extends Node

var laps_completed: int = -1
var current_player_path: PlayerPath

func count_lap() -> void:
	laps_completed += 1
	if not laps_completed == 0 and current_player_path.curve.point_count > 0:
		current_player_path.spawn_ghost()
	else:
		current_player_path.state = PlayerPath.State.RECORDING

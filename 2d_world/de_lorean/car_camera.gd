extends Camera2D

enum Positions {
	AHEAD,
	CENTERED,
	REVERSE,
}

const CAMERA_POSITIONS: Dictionary[Positions, Dictionary] = {
	Positions.AHEAD: {
		"position":Vector2(450,0),
		"zoom":Vector2(0.65,0.65)},
	Positions.CENTERED:{
		"position":Vector2.ZERO,
		"zoom":Vector2(0.8,0.8)},
	Positions.REVERSE:{
		"position":Vector2(-200,0),
		"zoom":Vector2(0.8,0.8)},
}

@export var player: DeLorean

var camera_position: Positions

func _physics_process(_delta: float) -> void:
	var player_movement_direction: float = player.velocity.normalized().dot(player.transform.x)
	var player_movement_speed: float = player.velocity.length()

	if player_movement_direction < 0:
		camera_position = Positions.REVERSE
	elif player_movement_speed > 200:
		camera_position = Positions.AHEAD
	else:
		camera_position = Positions.CENTERED
	_update_camera()


func _update_camera() -> void:
	var goal_zoom: Vector2 = CAMERA_POSITIONS.get(camera_position).zoom
	var goal_position: Vector2 = CAMERA_POSITIONS.get(camera_position).position
	var zoom_transition_speed: float = 0.001 if not camera_position == Positions.AHEAD else 0.0001
	var position_transition_speed: float = 1.0 if not camera_position == Positions.AHEAD else 0.4

	position = position.move_toward(goal_position, position_smoothing_speed * position_transition_speed)
	zoom = zoom.move_toward(goal_zoom,position_smoothing_speed * zoom_transition_speed)

extends Camera2D

enum Positions{AHEAD,CENTERED,REVERSE}

const CAMERA_POSITIONS:Dictionary[Positions,Dictionary] = {
	Positions.AHEAD: {
		"position":Vector2(450,0),
		"zoom":Vector2(0.75,0.75)},
	Positions.CENTERED:{
		"position":Vector2.ZERO,
		"zoom":Vector2(0.8,0.8)},
	Positions.REVERSE:{
		"position":Vector2(-200,0),
		"zoom":Vector2(0.8,0.8)},
	}

@export var player:DeLorian

var camera_position:Positions

func _physics_process(delta: float) -> void:
	var player_movement_direction = player.velocity.normalized().dot(player.transform.x)
	var player_movement_speed = player.velocity.length()

	if player_movement_direction < 0:
		camera_position = Positions.REVERSE
	elif player_movement_speed > 200:
		camera_position = Positions.AHEAD
	else:
		camera_position = Positions.CENTERED
	update_camera(delta)


func update_camera(_delta:float):
	var goal_zoom = CAMERA_POSITIONS.get(camera_position).zoom
	var goal_position = CAMERA_POSITIONS.get(camera_position).position
	var zoom_transition_speed = 0.001 if not camera_position == Positions.AHEAD else 0.0001
	var position_transition_speed:float = 1.0 if not camera_position == Positions.AHEAD else 0.4

	position = position.move_toward(goal_position, position_smoothing_speed * position_transition_speed)
	zoom = zoom.move_toward(goal_zoom,position_smoothing_speed * zoom_transition_speed)

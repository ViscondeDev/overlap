extends Node

signal got_power_up(power_up: PowerUp)
signal used_power_up
signal lap_completed

@export var current_level: Level
@export var ui: CanvasLayer

var power_up_selected: PowerUp
var power_up_coordinates: Array[Vector2i]
var powerups: Array[PowerUp] = [Focus.new(), Sprint.new(), Heal.new()]
var laps_completed: int = -1
var current_player_path: PlayerPath
var time_left: float
var timestamp: float
var clock: Dictionary[String,int] = {
		"seconds":0,
		"decimals":0,
}

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("special"):
		use_power_up()
	if current_player_path.state == PlayerPath.State.RECORDING:
		_tick_timer(delta)


func _tick_timer(delta: float) -> void:
	timestamp += delta
	time_left -= delta
	clock.seconds = int(time_left)
	clock.decimals = int((time_left - clock.seconds) * 100)


func get_time_pretty() -> String:
	return str("%02d" % clock.seconds,":","%02d" % clock.decimals)


func count_lap() -> void:
	laps_completed += 1
	if not laps_completed == 0 and current_player_path.curve.point_count > 0:
		current_player_path.spawn_ghost()
		time_left = current_level.time_limit
		lap_completed.emit()
	else:
		current_player_path.state = PlayerPath.State.RECORDING


func get_power_up(collectable: PoweUpCollectable) -> void:
	var powerup:PowerUp = powerups.pick_random().duplicate()
	power_up_selected = powerup
	got_power_up.emit()
	collectable.global_position = power_up_coordinates.pick_random()

func use_power_up() -> void:
	if power_up_selected == null: return
	get_tree().get_first_node_in_group("Player").add_child(power_up_selected)
	power_up_selected = null
	used_power_up.emit()

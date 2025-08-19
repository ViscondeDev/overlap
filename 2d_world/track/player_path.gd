class_name PlayerPath
extends Path2D

signal state_changed
signal snapshot_taken

enum State {
	IDLE,
	RECORDING,
}

@export var echo_scene: PackedScene
@export var player: DeLorian
@export var updates_per_second: int = 2

var time_count: float = 0
var state: State = State.IDLE:
	set(value):
		state = value
		state_changed.emit()


func _ready() -> void:
	curve = Curve2D.new()


func _physics_process(delta: float) -> void:
	if not state == State.RECORDING: return

	if _get_timer_tick(delta): _save_player_position()


func _get_timer_tick(delta: float) -> bool:
	time_count += delta
	var tick: float = 1.0 / updates_per_second
	var is_tick = true if time_count > tick else false
	if is_tick: time_count = 0
	return is_tick


func _save_player_position() -> void:
	const MINIMUM_OFFSET:Vector2 = Vector2(0,1)
	var last_point: Vector2 = curve.get_point_position(curve.point_count-1) if not curve.point_count == 0 else player.global_position
	var point: Vector2 = player.global_position if player.global_position != last_point else player.global_position + MINIMUM_OFFSET # Setting a 1 pixel offset ensure the point is recorded, even if there is no significant changes

	curve.add_point(point)
	snapshot_taken.emit()


func update_state(required_state) -> void:
	if required_state == state: return
	state = required_state


func spawn_ghost() -> void:
	var echo: Echo = echo_scene.instantiate()
	echo.player_path = self
	echo.global_position = curve.get_point_position(0)

	await get_tree().create_timer(1).timeout

	snapshot_taken.connect(echo.increment_point)
	add_child.call_deferred(echo)

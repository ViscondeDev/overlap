class_name PlayerPath
extends Path2D

enum State{IDLE,RECORDING}

@export var echo_scene:PackedScene
@export var player:DeLorian
@export var updates_per_second:int = 2

var time_count:float = 0

var state:State = State.IDLE:
	set(value):
		state = value
		state_changed.emit()

signal state_changed
signal snapshot_taken


func _ready() -> void:
	EventsManager.lap_ended.connect(spawn_ghost)
	curve = Curve2D.new()

	var timer := Timer.new()
	timer.wait_time = 1
	add_child(timer)
	timer.start()

	await timer.timeout

	state = State.RECORDING


func _physics_process(delta: float) -> void:
	if not state == State.RECORDING: return
	if _get_timer_tick(delta): _track_player(delta)
	if Input.is_action_just_pressed("special"): spawn_ghost()


func _get_timer_tick(delta:float) -> bool:
	time_count += delta
	var tick:float = 1.0/updates_per_second
	var is_tick = true if time_count > tick else false
	if is_tick: time_count = 0
	return is_tick


func _track_player(_delta:float) -> void:
	var last_point:Vector2 = curve.get_point_position(curve.point_count-1) if not curve.point_count == 0 else player.global_position
	const MINIMUM_OFFSET:Vector2 = Vector2(0,1)
	var point:Vector2 = player.global_position if player.global_position != last_point else player.global_position + MINIMUM_OFFSET

	curve.add_point(point)
	snapshot_taken.emit()


func spawn_ghost() -> void:
	var echo:Echo = echo_scene.instantiate()
	echo.player_path = self
	echo.global_position = curve.get_point_position(0)

	var timer := Timer.new()
	timer.wait_time = 0.3
	add_child(timer)
	timer.start()

	await timer.timeout

	timer.queue_free()
	snapshot_taken.connect(echo.follow_player)
	add_child.call_deferred(echo)


func update_state(required_state) -> void:
	if required_state == state: return
	state = required_state

class_name DeLorian
extends CharacterBody2D

signal engine_state_changed(state: EngineState)
signal tire_state_changed(state: TireState)

enum State {
	IDLE,
	ACTIVE,
	DEAD,
}
enum EngineState {
	SLOW,
	SPEEDING_UP,
	FAST,
	DEAD,
}
enum TireState {
	TRACTION,
	DRIFT,
}

@export_category("car settings")
@export var state: State = State.IDLE
@export var steering_max_angle := 15
@export var engine_power := 230
@export var friction := -250
@export var drag := -0.06
@export var braking := -600
@export var max_speed := 1200
@export var max_speed_reverse := 400
@export var speed_to_slip := 900
@export var traction_fast := 7
@export var traction_slow := 10
@export var wheels_distance := 54

var _acceleration := Vector2.ZERO
var _steering_direction: float = 0
var engine_state: EngineState = EngineState.SLOW:
	set(value):
		if value == engine_state: return
		engine_state_changed.emit(value)
		engine_state = value
var tire_state: TireState:
	set(value):
		if value == tire_state: return
		tire_state_changed.emit(value)
		tire_state = value


func _physics_process(delta: float) -> void:
	_acceleration = Vector2.ZERO
	_get_input()
	_calculate_steering(delta)
	var final_speed = clampf(_acceleration.length(), 0, max_speed)
	velocity += final_speed * _acceleration.normalized() * delta
	_apply_friction(delta)
	move_and_slide()
	_update_engine_state()


func _get_input() -> void:
	if state in [State.DEAD, State.IDLE]:
		_steering_direction = 0
		_acceleration = Vector2.ZERO
		return
	elif Input.is_action_pressed("move_up"):
		_acceleration = transform.x * engine_power
	elif Input.is_action_pressed("move_down"):
		_acceleration = transform.x * braking

	var turn: float = Input.get_axis("move_left", "move_right")
	_steering_direction = turn * deg_to_rad(steering_max_angle)


func _calculate_steering(delta) -> void:
	if not state == State.ACTIVE: return

	const UNALIGNEMENT_TO_DRIFT = 0.94
	var rear_wheel_position: Vector2 = position - transform.x * wheels_distance / 2.0
	var front_wheel_position: Vector2 = position + transform.x * wheels_distance / 2.0

	rear_wheel_position += velocity * delta
	front_wheel_position += velocity.rotated(_steering_direction) * delta

	var new_heading = rear_wheel_position.direction_to(front_wheel_position)
	var traction = traction_fast if velocity.length() > speed_to_slip else traction_slow
	var disalignement = new_heading.dot(velocity.normalized())

	if disalignement > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
		tire_state = TireState.DRIFT if disalignement < UNALIGNEMENT_TO_DRIFT else TireState.TRACTION
	else:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()


func _apply_friction(delta: float) -> void:
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag

	_acceleration = velocity.rotated(180) * delta if state == State.DEAD else _acceleration + (drag_force + friction_force)
	if _acceleration == Vector2.ZERO and velocity.length() < 20:
		velocity = Vector2.ZERO


func _update_engine_state():
	if state == State.DEAD: return
	if velocity.length() < 100:
		engine_state = EngineState.SLOW
	elif velocity.length() >= speed_to_slip:
		engine_state = EngineState.FAST
	else:
		engine_state = EngineState.SPEEDING_UP


func disable():
	if state == State.DEAD: return
	state = State.DEAD
	engine_state = EngineState.DEAD


func enable():
	state = State.ACTIVE

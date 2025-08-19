class_name DeLorian
extends CharacterBody2D

enum State{IDLE,ACTIVE,DEAD}
enum EngineState{SLOW,SPEEDING_UP,FAST,DEAD}
enum TireState{TRACTION,DRIFT}

@export_category("car settings")
@export var state:State = State.IDLE
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

var acceleration := Vector2.ZERO
var steer_direction:float = 0

var engine_state:EngineState = EngineState.SLOW:
	set(value):
		if value != engine_state:
			engine_state_changed.emit(value)
			engine_state = value

var tire_state:TireState:
	set(value):
		if value != tire_state:
			tire_state_changed.emit(value)
			tire_state = value

signal engine_state_changed(state:EngineState)
signal tire_state_changed(state:TireState)

func _physics_process(delta: float) -> void:
	acceleration = Vector2.ZERO
	_get_input()
	_calculate_steering(delta)
	velocity += clampf(acceleration.length(),0,max_speed) * acceleration.normalized() * delta
	_apply_friction(delta)
	move_and_slide()
	_update_engine_state()


func _get_input() -> void:
	if state in [State.DEAD,State.IDLE]:
		steer_direction = 0
		acceleration = Vector2.ZERO
		return
	elif Input.is_action_pressed("move_up"):
		acceleration = transform.x * engine_power
	elif Input.is_action_pressed("move_down"):
		acceleration = transform.x * braking

	var turn:float = Input.get_axis("move_left", "move_right")
	steer_direction = turn * deg_to_rad(steering_max_angle)


func _calculate_steering(delta) -> void:
	if not state == State.ACTIVE: return
	var rear_wheel = position - transform.x * wheels_distance / 2.0
	var front_wheel = position + transform.x * wheels_distance / 2.0
	# Advance the wheels' positions based on the current velocity, applying rotation to the front wheel
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	# Calculate the new heading based on the wheels' positions
	var new_heading = rear_wheel.direction_to(front_wheel)

	var traction = traction_fast if velocity.length() > speed_to_slip else traction_slow
	const UNALIGNEMENT_TO_DRIFT = 0.94

	var disalignement = new_heading.dot(velocity.normalized())
	if disalignement > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
		if disalignement < UNALIGNEMENT_TO_DRIFT:
			tire_state = TireState.DRIFT
		else:
			tire_state = TireState.TRACTION
	if disalignement < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()


func _apply_friction(delta) -> void:
	if acceleration == Vector2.ZERO and velocity.length() < 20:
		velocity = Vector2.ZERO

	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag

	if state == State.DEAD:
		acceleration = velocity.rotated(180)*delta
	else:
		acceleration += (drag_force + friction_force)


func _update_engine_state():
	if state == State.DEAD: return
	if velocity.length() < 100:
		engine_state = EngineState.SLOW
	elif velocity.length() >= speed_to_slip:
		engine_state = EngineState.FAST
	else:
		engine_state = EngineState.SPEEDING_UP


func disable():
	if state != State.DEAD:
		state = State.DEAD
		engine_state = EngineState.DEAD


func enable():
	state = State.ACTIVE

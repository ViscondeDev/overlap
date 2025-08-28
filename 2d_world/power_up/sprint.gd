class_name Sprint
extends PowerUp

var icon_texture: CompressedTexture2D = preload("res://2d_world/power_up/sprint.png")

const ENGINE_BOOST: int = 200
const MAX_SPEED_BOOST: int = 250

func _ready() -> void:
	_sprint()

func _sprint() -> void:
	player.engine_power += ENGINE_BOOST
	player.max_speed += MAX_SPEED_BOOST
	player.steering_max_angle += 2
	await get_tree().create_timer(2).timeout
	player.steering_max_angle -= 2
	player.engine_power -= ENGINE_BOOST
	player.max_speed -= MAX_SPEED_BOOST
	queue_free()

class_name Sprint
extends PowerUp

func _ready() -> void:
	_sprint()

func _sprint() -> void:
	player.engine_power += 500
	player.max_speed += 500
	player.steering_max_angle += 2
	await get_tree().create_timer(2).timeout
	player.steering_max_angle -= 2
	player.engine_power -= 500
	player.max_speed -= 500
	queue_free()

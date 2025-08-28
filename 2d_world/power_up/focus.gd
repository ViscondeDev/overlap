class_name Focus
extends PowerUp

func _ready() -> void:
	_focus()

func _focus() -> void:
	Engine.time_scale = 0.5
	player.steering_max_angle += 2
	await get_tree().create_timer(1.5).timeout
	player.steering_max_angle -= 2
	Engine.time_scale = 1
	queue_free()

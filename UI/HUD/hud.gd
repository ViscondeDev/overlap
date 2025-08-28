extends Control

func _ready() -> void:
	var health: Health =  get_tree().get_first_node_in_group("Health")
	health.health_changed.connect(update_health.bind(health))
	update_health(health)
	EventsManager.got_power_up.connect(display_powerup)
	EventsManager.used_power_up.connect(display_powerup)
	EventsManager.lap_completed.connect(display_laps)


func _process(_delta: float) -> void:
	$Timer.text = EventsManager.get_time_pretty()


func display_powerup() -> void:
	var powerup:PowerUp = EventsManager.power_up_selected
	if powerup is Focus:
		$TextureRect.texture = load("res://2d_world/power_up/focus.png")
	elif powerup is Sprint:
		$TextureRect.texture = load("res://2d_world/power_up/sprint.png")
	elif powerup is Heal:
		$TextureRect.texture = load("res://2d_world/power_up/heal.png")
	else:
		$TextureRect.texture = null


func display_laps() -> void:
	$Laps.text = str("Laps : %02d" % EventsManager.laps_completed)


func update_health(health: Health) -> void:
	$ProgressBar.max_value = health.max_health
	$ProgressBar.value = health.current_health

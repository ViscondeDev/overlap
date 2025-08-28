extends Control

@onready var timer: Label = %Timer
@onready var laps_display: Label = %LapsDisplay
@onready var selected_power_up: TextureRect = %SelectedPowerUp
@onready var health_bar: ProgressBar = %HealthBar



func _ready() -> void:
	var health: Health =  get_tree().get_first_node_in_group("Health")
	health.health_changed.connect(update_health.bind(health))
	update_health(health)
	EventsManager.got_power_up.connect(display_powerup)
	EventsManager.used_power_up.connect(display_powerup)
	EventsManager.lap_completed.connect(display_laps)


func _process(_delta: float) -> void:
	timer.text = EventsManager.get_time_pretty()


func display_powerup() -> void:
	var powerup:PowerUp = EventsManager.current_level.power_up_selected
	if powerup == null:
		selected_power_up.texture = null
	else:
		selected_power_up.texture = powerup.icon_texture


func display_laps() -> void:
	laps_display.text = str("Laps : %02d" % EventsManager.laps_completed)


func update_health(health: Health) -> void:
	health_bar.max_value = health.max_health
	health_bar.value = health.current_health

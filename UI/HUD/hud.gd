extends Control

func _process(delta: float) -> void:
	$Timer.text = EventsManager.get_time_pretty()
	$Laps.text = str("Laps : %02d" % EventsManager.laps_completed)

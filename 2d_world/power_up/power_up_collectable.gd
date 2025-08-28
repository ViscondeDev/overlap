class_name PoweUpCollectable
extends Area2D

signal power_up_collected

var active: bool = false

func _ready() -> void:
	power_up_collected.connect(EventsManager.get_power_up.bind(self))
	EventsManager.lap_completed.connect(_activate)


func _activate() -> void:
	active = true


func _on_body_entered(_body: Node2D) -> void:
	if not active: return
	power_up_collected.emit()
	active = false

class_name PoweUpCollectable
extends Area2D

signal power_up_collected

func _ready() -> void:
	power_up_collected.connect(EventsManager.get_power_up)


func _on_body_entered(body: Node2D) -> void:
	power_up_collected.emit()

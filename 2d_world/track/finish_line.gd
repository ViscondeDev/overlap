@tool
class_name FinishLine
extends Area2D

signal lap_over

@export_enum("Main","Half") var type: String:
	set(value):
		name = value
		type = value
@export var main_line: FinishLine

var active: bool = true

func _ready() -> void:
	body_entered.connect(_detect_player)
	match type:
		"Main":
			lap_over.connect(EventsManager.count_lap)
		"Half":
			if main_line == null:
				push_error("Missing refference at counter finish line")


func _detect_player(body: Node2D) -> void:
	if not body is DeLorean or not active: return
	match type:
		"Main":
			active = false
			lap_over.emit()
		"Half":
			main_line.active = true

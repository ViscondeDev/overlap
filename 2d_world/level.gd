class_name Level
extends Node2D

@export var time_limit: int

func _ready() -> void:
	EventsManager.current_level = self
	EventsManager.time_left = time_limit

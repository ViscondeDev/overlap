class_name Level
extends Node2D

@export var time_limit: int
@export var powerup_scripts: Array[Script] = [
		preload("res://2d_world/power_up/focus.gd"),
		preload("res://2d_world/power_up/heal.gd"),
		preload("res://2d_world/power_up/sprint.gd")]

var powerups: Array[PowerUp]
var power_up_coordinates: Array[Vector2i]
var power_up_selected: PowerUp:
	set(value):
		power_up_selected = value
		EventsManager.got_power_up.emit()

func _ready() -> void:
	EventsManager.current_level = self
	EventsManager.time_left = time_limit
	_populate_power_ups()


func _populate_power_ups() -> void:
	powerups.clear()
	for powerup in powerup_scripts:
		if powerup == null: return
		var instance: PowerUp = powerup.new()
		powerups.append(instance)


func get_power_up(collectable: PoweUpCollectable) -> void:
	var powerup:PowerUp = powerups.pick_random().duplicate()
	power_up_selected = powerup
	collectable.global_position = power_up_coordinates.pick_random()


func use_power_up() -> void:
	if power_up_selected == null: return
	get_tree().get_first_node_in_group("Player").add_child(power_up_selected)
	power_up_selected = null
	EventsManager.used_power_up.emit()

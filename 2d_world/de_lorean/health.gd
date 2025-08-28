class_name Health
extends Area2D

signal health_changed

@export var max_health: int = 300
@export var speed_to_damage_ratio: float = 0.03

var current_health:int:
	set(value):
		value = clamp(value, 0, max_health)
		current_health = value
		health_changed.emit()
		if current_health <= 0:
			player.disable()


@onready var player: DeLorean = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	current_health = max_health

func _on_body_entered(body: Node2D) -> void:
	if not body is PhysicsBody2D: return
	current_health -= _calculate_damage(player, body)

func _calculate_damage(body1: DeLorean, body2: PhysicsBody2D) -> int:
	var _speed1: Vector2 = body1.velocity
	var _speed2: Vector2 = body2.velocity if body2 is CharacterBody2D else Vector2.ZERO
	var _relative_velocity :Vector2 = _speed2 - _speed1
	var _angle: Vector2 = (body2.global_position - body1.global_position).normalized()
	var _tangent: float = _relative_velocity.normalized().dot(_angle)
	var _damage = int((_relative_velocity * _tangent).length() * speed_to_damage_ratio)
	return _damage

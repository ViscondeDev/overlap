class_name Health
extends Area2D

signal health_changed

@export var max_health: int = 300
@export var speed_to_damage_ratio: float = 0.03

var current_health:int:
	set(value):
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

func _calculate_damage(body1: CharacterBody2D, body2: PhysicsBody2D) -> int:
	var speed1: Vector2 = body1.velocity
	var speed2: Vector2 = body2.velocity if body2 is CharacterBody2D else Vector2.ZERO
	var relative_velocity :Vector2 = speed2 - speed1
	var angle: Vector2 = (body2.global_position - body1.global_position).normalized()
	var tangent: float = relative_velocity.normalized().dot(angle)
	var damage = int((relative_velocity * tangent).length() * speed_to_damage_ratio)
	return damage

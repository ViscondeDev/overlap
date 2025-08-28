class_name Heal
extends PowerUp

func _ready() -> void:
	var health: Health = get_tree().get_first_node_in_group("Health")
	health.current_health += health.max_health / 2
	clamp(health.current_health, 0, health.max_health)

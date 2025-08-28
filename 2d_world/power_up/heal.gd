class_name Heal
extends PowerUp

var icon_texture: CompressedTexture2D = preload("res://2d_world/power_up/heal.png")

func _ready() -> void:
	var health: Health = get_tree().get_first_node_in_group("Health")
	health.current_health += health.max_health / 2

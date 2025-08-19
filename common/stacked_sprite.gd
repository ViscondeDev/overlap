@tool
class_name StackingSprites
extends Sprite2D

@export_category("Stacking")
@export var render_on_editor: bool = false:
	set(value):
		if value:
			_render_sprites.call_deferred()
		else :
			_clear_sprites()
		render_on_editor = value
@export var spacing: float = 1.6
@export_range(-0.1,0.1) var progressive_rotation: float
@export var center_layer: int = 9
@export var cap_layer: int = -1

var to_align_elements: Array[Node2D]
var finished_staging: bool

@onready var layers_axis := Marker2D.new()


func _ready():
	if not render_on_editor and Engine.is_editor_hint(): return
	_clear_sprites()
	_render_sprites()
	add_child(layers_axis)
	if Engine.is_editor_hint(): return
	for element in get_children():
		to_align_elements.append(element)


func _process(_delta):
	if not render_on_editor and Engine.is_editor_hint(): return
	if not is_node_ready(): return
	for sprite in layers_axis.get_children():
		layers_axis.global_rotation = 0
		sprite.rotation = (global_rotation + sprite.get_index() * progressive_rotation)


func _clear_sprites() -> void:
	for sprite in layers_axis.get_children():
		sprite.queue_free()


func _render_sprites() -> void:
	if layers_axis == null: return
	for i in range(0, hframes):
		var next_sprite = Sprite2D.new()
		next_sprite.texture = texture
		next_sprite.hframes = hframes
		next_sprite.flip_h = flip_h
		next_sprite.frame = i
		next_sprite.position.y = -i * spacing
		next_sprite.scale = scale
		next_sprite.light_mask = light_mask
		next_sprite.z_index = z_index
		layers_axis.add_child(next_sprite)

		var layer = next_sprite.get_index()
		if cap_layer > 0 and layer > cap_layer: return
		if not layer == center_layer: continue
		if to_align_elements.size() == 0: continue

		for child in to_align_elements:
			child.reparent(next_sprite)
			child.global_position = next_sprite.global_position + child.position

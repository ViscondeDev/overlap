class_name StaticTileMapLayer
extends TileMapLayer

@onready var boudaries := StaticBody2D.new()
@onready var level := Node2D.new()

func _ready() -> void:
	if Engine.is_editor_hint(): return
	get_parent().add_child.call_deferred(level)
	export_boundaries()
	var level_screenshot: Image = await export_image()

	var sprite = Sprite2D.new()
	sprite.texture = ImageTexture.create_from_image(level_screenshot)
	sprite.centered = false
	sprite.z_index = -1
	level.add_child(sprite)


func _offset_polygons_to_tile(points:PackedVector2Array,tile_coord:Vector2i):
	var new_points:PackedVector2Array
	for point in points:
		point += tile_coord * tile_set.tile_size as Vector2
		point += tile_set.tile_size/2 as Vector2
		new_points.append(point)

	return new_points


func _create_collision_shape(points:PackedVector2Array) -> void:
	var collision_shape := CollisionShape2D.new()
	var shape = ConvexPolygonShape2D.new()
	shape.points = points
#
	collision_shape.shape = shape
	boudaries.add_child(collision_shape)
	collision_shape.owner = get_tree().edited_scene_root


func _clear_boundaries():
	for child in boudaries.get_children():
		child.queue_free()


func export_image() -> Image:
	var used_rect: Rect2i = get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		push_error("Empty tilemap")

	var tile_size: Vector2i = tile_set.tile_size
	var img_size := Vector2i(used_rect.size.x * tile_size.x, used_rect.size.y * tile_size.y)

	var snapshot_viewport := SubViewport.new()
	snapshot_viewport.size = img_size
	snapshot_viewport.transparent_bg = true
	snapshot_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

	level.add_child(snapshot_viewport)
	reparent.call_deferred(snapshot_viewport)
	position = -Vector2(used_rect.position) * Vector2(tile_size)

	await get_tree().process_frame
	await get_tree().process_frame

	var image := snapshot_viewport.get_texture().get_image()
	snapshot_viewport.queue_free()
	return image


func export_boundaries() -> void:
	const PHYSICS_LAYER := 0
	var road_tiles_coordinates: Array[Vector2i]
	for tile_coords in get_used_cells():
		var tile_data: TileData = get_cell_tile_data(tile_coords)
		if tile_data.terrain == 0:
			road_tiles_coordinates.append(tile_coords * tile_set.tile_size)

		if tile_data.get_collision_polygons_count(PHYSICS_LAYER) == 0: continue

		for polygon in range(0, tile_data.get_collision_polygons_count(PHYSICS_LAYER)):
			var polygon_points: PackedVector2Array = tile_data.get_collision_polygon_points(PHYSICS_LAYER, polygon)
			if polygon_points.size() == 0: continue
			polygon_points = _offset_polygons_to_tile(polygon_points,tile_coords)
			_create_collision_shape(polygon_points)
	level.add_child(boudaries)
	EventsManager.power_up_coordinates = road_tiles_coordinates

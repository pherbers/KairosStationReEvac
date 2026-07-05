extends Node2D
class_name GridWorld

@export var tile_map_ground: TileMapLayer
@export var tile_map_collide: TileMapLayer

## Grid: negative values are collision, positive are interactions
var grid_occupancy: PackedByteArray
var grid_interaction: PackedInt64Array

var entities: Dictionary[int, GridEntity]

var width: int
var height: int

var _registration_list: Array[GridEntity]

func _ready() -> void:
    width = tile_map_ground.get_used_rect().end.x
    height = tile_map_ground.get_used_rect().end.y
    grid_occupancy.resize(width*height)
    grid_occupancy.fill(0)
    grid_interaction.resize(width*height)
    grid_interaction.fill(0)
    
    for y in range(height):
        for x in range(width):
            var tiledata = tile_map_collide.get_cell_tile_data(Vector2i(x, y))
            if tiledata != null:
                if tiledata.get_collision_polygons_count(0) > 0:
                    _add_collision(Vector2i(x, y))

func _process(_delta: float) -> void:
    while not _registration_list.is_empty():
        _register_entity_now(_registration_list.pop_back())

func register_entity(entity: GridEntity):
    _registration_list.append(entity)

func _register_entity_now(entity: GridEntity):
    if not entities.has(entity.get_instance_id()):
        entity.on_tile_changed.connect(_entity_moved)
        entities[entity.get_instance_id()] = entity
        if entity.blocking:
            _add_collision(entity.current_tile_pos)

func unregister_entity(entity: GridEntity):
    if entities.has(entity.get_instance_id()):
        entity.on_tile_changed.disconnect(_entity_moved)
        entities.erase(entity.get_instance_id())
        if entity.blocking:
            _remove_collision(entity.current_tile_pos)

func _entity_moved(entity: GridEntity, old_pos: Vector2i, new_pos: Vector2i):
    if entity.blocking:
        _remove_collision(old_pos)
        _add_collision(new_pos)

func set_interactible(tile: Vector2i, interactible: GridInteractible):
    grid_interaction.set(tile.y * width + tile.x, interactible.get_instance_id())

func _add_collision(tile: Vector2i):
    var c = grid_occupancy.decode_u8(tile.y * width + tile.x)
    grid_occupancy.encode_u8(tile.y * width + tile.x, c + 1)
    
func _remove_collision(tile: Vector2i):
    var c = grid_occupancy.decode_u8(tile.y * width + tile.x)
    if c < 0:
        push_error("Number of colliders at {tile.x}, {tile.y} is negative! Something went very wrong!")
    grid_occupancy.encode_u8(tile.y * width + tile.x, c - 1)
    
func interact(tile: Vector2i) -> bool:
    var interactible_id = grid_interaction.get(tile.y * width + tile.x)
    if interactible_id == 0:
        return false
    var obj = instance_from_id(interactible_id)
    if obj == null or obj is not GridInteractible:
        return false
    var npc = obj as GridInteractible
    npc.interact()
    return true

func check_collision(tile: Vector2i) -> bool:
    return grid_occupancy.decode_u8(tile.y * width + tile.x) > 0

func get_entities_at_tile(tile: Vector2i) -> Array[GridEntity]:
    # could be improved
    return entities.values().filter(func(e): return e.current_tile_pos == tile)

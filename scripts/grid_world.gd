extends Node2D
class_name GridWorld

@export var tile_map_ground: TileMapLayer
@export var tile_map_collide: TileMapLayer

## Grid: negative values are collision, positive are interactions
var grid_occupancy: PackedByteArray
var grid_interaction: PackedInt64Array

var width: int
var height: int

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
                    set_collision(Vector2i(x, y), true)
                    
    var grid_characters = find_children("*", "NPC") as Array[NPC]
    for character in grid_characters:
        set_collision(character.current_tile_pos, true)
        set_interactible(character.current_tile_pos, character)

func set_interactible(tile: Vector2i, interactible: NPC):
    grid_interaction.set(tile.y * width + tile.x, interactible.get_instance_id())

func set_collision(tile: Vector2i, collide: bool = true):
    grid_occupancy.encode_u8(tile.y * width + tile.x, collide)
    
func interact(tile: Vector2i) -> bool:
    var interactible_id = grid_interaction.get(tile.y * width + tile.x)
    if interactible_id == 0:
        return false
    var obj = instance_from_id(interactible_id)
    if obj == null or obj is not NPC:
        return false
    var npc = obj as NPC
    npc.interact()
    return true

func check_collision(tile: Vector2i) -> bool:
    return grid_occupancy.decode_u8(tile.y * width + tile.x) > 0

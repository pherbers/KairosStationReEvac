extends Camera2D

@export var target: Node2D
@export var tile_map: TileMapLayer

func _ready() -> void:
    if tile_map != null:
        var limit_rect = tile_map.get_used_rect()
        limit_top    = floor(tile_map.to_global(tile_map.map_to_local(limit_rect.position)).y - float(tile_map.tile_set.tile_size.y) / 2)
        limit_left   = floor(tile_map.to_global(tile_map.map_to_local(limit_rect.position)).x - float(tile_map.tile_set.tile_size.x) / 2)
        limit_bottom = floor(tile_map.to_global(tile_map.map_to_local(limit_rect.end)).y - float(tile_map.tile_set.tile_size.y) / 2)
        limit_right  = floor(tile_map.to_global(tile_map.map_to_local(limit_rect.end)).x - float(tile_map.tile_set.tile_size.x) / 2)

func _process(_delta: float) -> void:
    position = target.position

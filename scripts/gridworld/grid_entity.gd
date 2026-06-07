extends Node2D
class_name GridEntity

@export var world: GridWorld

@export var current_tile_pos: Vector2i:
    set (new_pos):
        var old_pos = current_tile_pos
        current_tile_pos = new_pos
        on_tile_changed.emit(self, old_pos, new_pos)


@export var blocking = true:
    set(value):
        if blocking == true and value == false:
            world._remove_collision(current_tile_pos)
        if blocking == false and value == true:
            world._add_collision(current_tile_pos)
        blocking = value

signal on_tile_changed(entity: GridEntity, old_pos: Vector2i, new_pos: Vector2i)

func _ready() -> void:
    if world == null:
        world = find_parent("GridWorld")
    
    current_tile_pos = world.tile_map_ground.local_to_map(position)
    world.register_entity(self)

func _process(_delta: float) -> void:
    position = world.tile_map_ground.map_to_local(current_tile_pos)

extends Node2D
class_name GridCharacter

@export var world: GridWorld

@export var current_tile_pos: Vector2i
@export var target_tile_pos: Vector2i
@export var previous_tile_pos: Vector2i
@export var tile_move_time: float = 0.96/2
@export var facing: Direction = Direction.SOUTH
@export var state: State = State.IDLE

@export var anim_idle_name: String = "idle"
@export var anim_walk_name: String = "walk"

@onready var _sprite = $Sprite as AnimatedSprite2D

enum State {
    IDLE, MOVING
}

enum Direction {
    NORTH = 0, WEST = 1, SOUTH = 2, EAST = 3
}

var _movement_timer: float = 0.

func move(dir: Direction) -> bool:
    if state != State.IDLE:
        return false
    var move_d: Vector2i
    match dir:
        Direction.NORTH:
            move_d = Vector2i.UP
        Direction.SOUTH:
            move_d = Vector2i.DOWN
        Direction.WEST:
            move_d = Vector2i.LEFT
        Direction.EAST:
            move_d = Vector2i.RIGHT
        _:
            move_d = Vector2i.ZERO
    
    facing = dir
    return go_to_tile(current_tile_pos + move_d)
    
func go_to_tile(tile: Vector2i, collide=true) -> bool:
    var in_bounds = world.tile_map_ground.get_used_rect().has_point(tile)
    if !in_bounds:
        return false
        
    if collide and world.check_collision(tile):
        return false
    
    target_tile_pos = tile
    previous_tile_pos = current_tile_pos
    _movement_timer = tile_move_time
    
    return true

    
func move_north():
    move(Direction.NORTH)
func move_south():
    move(Direction.SOUTH)
func move_west():
    move(Direction.WEST)
func move_east():
    move(Direction.EAST)
    
func face_towards(tile: Vector2i):
    var look_delta = current_tile_pos - tile
    if look_delta == Vector2i.ZERO:
        return
    if look_delta.x < look_delta.y and look_delta.x < -look_delta.y:
        facing = Direction.EAST
    elif look_delta.x < look_delta.y and look_delta.x > -look_delta.y:
        facing = Direction.NORTH
    elif look_delta.x > look_delta.y and look_delta.x < -look_delta.y:
        facing = Direction.SOUTH
    elif look_delta.x > look_delta.y and look_delta.x > -look_delta.y:
        facing = Direction.WEST

func get_look_at_tile() -> Vector2i:
    var d
    match facing:
        Direction.NORTH:
            d = Vector2i.UP
        Direction.SOUTH:
            d = Vector2i.DOWN
        Direction.WEST:
            d = Vector2i.LEFT
        Direction.EAST:
            d = Vector2i.RIGHT
        _:
            d = Vector2i.ZERO
    return current_tile_pos + d

func _ready() -> void:
    if world == null:
        world = find_parent("GridWorld")
    
    current_tile_pos = world.tile_map_ground.local_to_map(position)
    target_tile_pos = current_tile_pos
    previous_tile_pos = current_tile_pos

func _process(delta: float) -> void:
    if _movement_timer > 0 and tile_move_time > 0:
        state = State.MOVING
        _movement_timer -= delta
        _sprite.animation = anim_walk_name
        var tile_move_p = 1 - _movement_timer / tile_move_time
        position = lerp(world.tile_map_ground.map_to_local(previous_tile_pos), world.tile_map_ground.map_to_local(target_tile_pos), tile_move_p)
        if _movement_timer <= 0:
            current_tile_pos = target_tile_pos
            state = State.IDLE
    else:
        state = State.IDLE
        position = world.tile_map_ground.map_to_local(current_tile_pos)
        _sprite.animation = anim_idle_name

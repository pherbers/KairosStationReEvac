extends GridCharacter

class_name PlayerCharacter

var _move_input_queue: int = -1
var _last_input: int = -1

func _process(delta: float) -> void:
    super._process(delta)
    _move()
    if Input.is_action_just_pressed("Interact") and state == State.IDLE:
        world.interact(get_look_at_tile())
    
func _move():
    var move_dir = -1
    if Input.is_action_pressed("North")     or Input.is_action_just_pressed("North"):
        move_dir = Direction.NORTH
    elif Input.is_action_pressed("South")   or Input.is_action_just_pressed("South"):
        move_dir = Direction.SOUTH
    elif Input.is_action_pressed("East")    or Input.is_action_just_pressed("East"):
        move_dir = Direction.EAST
    elif Input.is_action_pressed("West")    or Input.is_action_just_pressed("West"):
        move_dir = Direction.WEST
    if state == State.MOVING and move_dir >= 0 and move_dir != _last_input:
        _move_input_queue = move_dir
    if _move_input_queue >= 0:
        move_dir = _move_input_queue
    if move_dir >= 0 and state != State.MOVING:
        _last_input = move_dir
        _move_input_queue = -1
        move(move_dir)
    

extends Node
class_name GameState

enum PlayState {
    SELECT, PLAY, REPLAY
}

signal playStateChanged(newState: PlayState)

@export var playState: PlayState:
    set (newValue):
        playState = newValue
        playStateChanged.emit(playState)
        print("New Play State: " + str(playState))

@export var world: GridWorld

# Crewmate control
@export var selected_crewmate: Crewmate = null
var _move_input_queue: int = -1
var _last_input: int = -1

func _process(delta: float) -> void:
    if playState == PlayState.PLAY:
        _process_play(delta)

func _process_play(_delta: float):
    if selected_crewmate != null:
        _move_crewmate()
    else:
        playState = PlayState.SELECT

func _move_crewmate():
    var move_dir = -1
    if Input.is_action_pressed("North")     or Input.is_action_just_pressed("North"):
        move_dir = GridCharacter.Direction.NORTH
    elif Input.is_action_pressed("South")   or Input.is_action_just_pressed("South"):
        move_dir = GridCharacter.Direction.SOUTH
    elif Input.is_action_pressed("East")    or Input.is_action_just_pressed("East"):
        move_dir = GridCharacter.Direction.EAST
    elif Input.is_action_pressed("West")    or Input.is_action_just_pressed("West"):
        move_dir = GridCharacter.Direction.WEST
    if selected_crewmate.state == GridCharacter.State.MOVING and move_dir >= 0 and move_dir != _last_input:
        _move_input_queue = move_dir
    if _move_input_queue >= 0:
        move_dir = _move_input_queue
    if move_dir >= 0 and selected_crewmate.state != GridCharacter.State.MOVING:
        _last_input = move_dir
        _move_input_queue = -1
        selected_crewmate.move(move_dir)
    if Input.is_action_just_pressed("Interact") and selected_crewmate.state == GridCharacter.State.IDLE:
        world.interact(selected_crewmate.get_look_at_tile())
    

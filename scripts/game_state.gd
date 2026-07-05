extends Node
class_name GameState

enum PlayState {
    SELECT, PLAY, REPLAY, EXPLODE
}

enum {
    ACTION_MOVE_NORTH, ACTION_MOVE_WEST, ACTION_MOVE_SOUTH, ACTION_MOVE_EAST, ACTION_INTERACT
}

signal on_play_state_changed(new_state: PlayState)
signal on_countdown_changed(ticks_left: int)
signal on_explosion()

@export var play_state: PlayState:
    set (new_value):
        var old_value = play_state
        play_state = new_value
        _play_state_changed(old_value, new_value)

@export var world: GridWorld

@export var countdown_max = 20
@export var countdown = 0

# Crewmate control
@export var selected_crewmate: Crewmate = null
var _move_input_queue: int = -1
var _last_input: int = -1

var crewmates: Array

func _ready():
    crewmates = get_tree().current_scene.find_children("*", "Crewmate") as Array

func _process(delta: float) -> void:
    if play_state == PlayState.PLAY:
        _process_play(delta)

func _process_play(_delta: float):
    if countdown <= 0:
        # everything explode !!!
        return
    if selected_crewmate != null:
        _move_crewmate()
    else:
        play_state = PlayState.SELECT

func _move_crewmate():
    var action = -1
    if Input.is_action_pressed("North")     or Input.is_action_just_pressed("North"):
        action = ACTION_MOVE_NORTH
    elif Input.is_action_pressed("South")   or Input.is_action_just_pressed("South"):
        action = ACTION_MOVE_SOUTH
    elif Input.is_action_pressed("East")    or Input.is_action_just_pressed("East"):
        action = ACTION_MOVE_EAST
    elif Input.is_action_pressed("West")    or Input.is_action_just_pressed("West"):
        action = ACTION_MOVE_WEST
    if Input.is_action_just_pressed("Interact"):
        action = ACTION_INTERACT
    if selected_crewmate.state == GridCharacter.State.MOVING and action >= 0 and action != _last_input:
        _move_input_queue = action
    if _move_input_queue >= 0:
        action = _move_input_queue
    if action >= ACTION_MOVE_NORTH and selected_crewmate.state != GridCharacter.State.MOVING:
        _last_input = action
        _move_input_queue = -1
        var success = false
        if action <= ACTION_MOVE_EAST:
            success = selected_crewmate.move(action)
        elif action == ACTION_INTERACT:
            success = world.interact(selected_crewmate.get_look_at_tile())
        
        # only count down if actually interacted or moved
        if success:
            _countdown_tick()

func _countdown_tick():
    countdown -= 1
    on_countdown_changed.emit(countdown)
    if countdown == 0:
        $ExplosionTimer.start()
        on_explosion.emit()

func _play_state_changed(old_state, new_state):
    if new_state == PlayState.PLAY and old_state != PlayState.PLAY:
        countdown = countdown_max
        on_countdown_changed.emit(countdown)
    if new_state == PlayState.SELECT:
        countdown = countdown_max
        for c in crewmates:
            c.reset_crewmate()
    if new_state == PlayState.EXPLODE:
        explode()

    on_play_state_changed.emit(new_state)
    print("New Play State: " + str(play_state))

func reset_play_state():
    play_state = PlayState.SELECT

func explode():
    await get_tree().create_timer(2.).timeout
    play_state = PlayState.SELECT

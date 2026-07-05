extends GridCharacter
class_name Crewmate

var game: GameState
@export var is_in_control = false
var _initial_position: Vector2i

func _ready():
    super()
    
    _initial_position = current_tile_pos
    
    game = $/root/MainScene/GameState
    game.on_play_state_changed.connect(playStateChanged)
    playStateChanged(game.play_state)
    on_move_finished.connect(move_finished)

func playStateChanged(playState):
    if playState == GameState.PlayState.PLAY:
        $SelectButton.hide()
        if is_in_control:
            anim_idle_name = "standing_calm"
            anim_walk_name = "running_calm"
        else:
            anim_idle_name = "standing_panic"
            anim_walk_name = "running_panic"
        _sprite.flip_h = false
    elif playState == GameState.PlayState.SELECT:
        $SelectButton.show()
        is_in_control = false
        anim_idle_name = "standing_panic"
        anim_walk_name = "running_panic"
        _sprite.flip_h = false
    elif playState == GameState.PlayState.REPLAY:
        $SelectButton.hide()
        is_in_control = false
        anim_idle_name = "standing_calm"
        anim_walk_name = "running_calm"
        _sprite.flip_h = false
    _sprite.play(anim_idle_name)

func select_crewmate():
    if game.play_state == GameState.PlayState.SELECT:
        is_in_control = true
        game.selected_crewmate = self
        game.play_state = GameState.PlayState.PLAY

func move_finished(_tile):
    # check for fire
    for e in world.get_entities_at_tile(current_tile_pos):
        if e is GridFire:
            if e.spawned:
                call_deferred("death")

func _process(delta: float) -> void:
    super._process(delta)
    
func reset_crewmate():
    current_tile_pos = _initial_position

func death():
    anim_idle_name = "death"
    _sprite.play("death")
    if is_in_control:
        is_in_control = false
        game.play_state = GameState.PlayState.EXPLODE

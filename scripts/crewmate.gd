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

func playStateChanged(playState):
    if playState == GameState.PlayState.PLAY:
        $SelectButton.hide()
        if is_in_control:
            anim_idle_name = "standing_calm"
            anim_walk_name = "running_calm"
        else:
            anim_idle_name = "standing_panic"
            anim_walk_name = "running_panic"
    elif playState == GameState.PlayState.SELECT:
        $SelectButton.show()
        is_in_control = false
        anim_idle_name = "standing_panic"
        anim_walk_name = "running_panic"
    elif playState == GameState.PlayState.REPLAY:
        $SelectButton.hide()
        is_in_control = false
        anim_idle_name = "standing_calm"
        anim_walk_name = "running_calm"

func select_crewmate():
    if game.play_state == GameState.PlayState.SELECT:
        is_in_control = true
        game.selected_crewmate = self
        game.play_state = GameState.PlayState.PLAY

func _process(delta: float) -> void:
    super._process(delta)
    
func reset_crewmate():
    current_tile_pos = _initial_position

extends Label

func _ready():
    var gs = $/root/MainScene/GameState as GameState
    gs.on_countdown_changed.connect(_on_countdown_changed)
    gs.on_play_state_changed.connect(_on_playstate_changed)
    
func _on_countdown_changed(down_to):
    text = str(down_to)
    
func _on_playstate_changed(new_state):
    if new_state == GameState.PlayState.SELECT:
        visible = false
    else:
        visible = true

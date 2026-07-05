extends GridEntity
class_name GridFire

@export var spawn_tick = 0

var spawned = false

@onready var _sprite = $Sprite

@onready var game_state: GameState = $/root/MainScene/GameState

func _spawn() -> void:
    _sprite.pause()
    _sprite.visible = false
    
    game_state.on_countdown_changed.connect(countdown_change)
    

func countdown_change(ticks_left):
    if not spawned and game_state.countdown_max - ticks_left >= spawn_tick:
        spawned = true
        _sprite.visible = true
        _sprite.play("explosion")

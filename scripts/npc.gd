extends GridCharacter

class_name NPC

@export var npc_data: NPCData


func interact():
    var player = $/root/World/PlayerCharacter as PlayerCharacter
    if player != null:
        face_towards(player.current_tile_pos)
    print("Interacting with " + npc_data.name)

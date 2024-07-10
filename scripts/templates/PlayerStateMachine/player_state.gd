# meta-name: Player State
# meta-default: true
# meta-space-indent: 4

class_name PlayerState
extends PlayerStateMachine


func _ready():
	super._ready()


func enter() -> void:
	pass


func process_player() -> void:
	pass


#func process_movement_animations() -> void:
	#player.character.idle_animations.active = player.lock_on_target != null
	#player.character.movement_animations.dir =player.input_direction


func exit() -> void:
	pass

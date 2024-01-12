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
#	player.character.movement_animations.move(
#		player.input_direction,
#		player.lock_on_target != null, 
#		false
#	)


func exit() -> void:
	pass

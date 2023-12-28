class_name DizzySystem
extends Node3D


@export var finisher_distance: float = 1.5


var dizzy_victim: DizzyComponent:
	set(value):
		if dizzy_victim == value:
			return
		saved_victim = dizzy_victim
		dizzy_victim = value

# save def: keep and store up for future use.
# when the dizzy victim is killed, dizzy_victim will
# instantly be set to null afterwards. but some
# behaviour still needs to check which entity
# was the victim.
var saved_victim: DizzyComponent

var can_kill_victim: bool = false

# this is true when there is a victim and the player
# has pressed the attack button to execute them.
# it will be false once the attack animation concludes.
var victim_being_killed: bool = false

var dizzy_victim_killed: bool = false

@onready var player: Player = Globals.player


func _process(_delta):
#	prints(victim_being_killed, saved_victim, dizzy_victim)
	
	if victim_being_killed:
		return
	elif not dizzy_victim:
		# after the attack concludes, saved victim is no
		# longer needed
		saved_victim = null
		return
	
	if not dizzy_victim.instability_component.full_instability_from_parry and \
	dizzy_victim.entity.global_position.distance_to(player.global_position) > finisher_distance:
		can_kill_victim = false
	else:
		can_kill_victim = true

class_name DizzySystem
extends Node3D


signal dizzy_victim_killed


# the current victim that can be finished
var dizzy_victim: DizzyComponent:
	set(value):
		if dizzy_victim == value: return
		saved_victim = dizzy_victim
		dizzy_victim = value

# save def: keep and store up for future use.
# when the dizzy victim is killed, dizzy_victim will
# instantly be set to null afterwards. but some
# behaviour still needs to check which entity
# was the victim.
var saved_victim: DizzyComponent

# whether the player should be in that cinematic like
# state ready to finish the victim, or whether they
# should live life normally
var readied_finisher: bool = false

# whether pressing attack at this stage should actually
# go about finishing the victim. used by crosshair and
# player dizzy finisher states
var can_kill_victim: bool = false

# this is true when there is a victim and the player
# has pressed the attack button to execute them.
# it will be false once the attack animation concludes.
var victim_being_killed: bool = false

var finisher_distance: float = 1.5

@onready var player: Player = Globals.player


func _process(_delta):
	#prints(victim_being_killed, saved_victim, dizzy_victim, readied_finisher)
	
	if victim_being_killed:
		return
		
	# after the attack concludes, saved victim is no longer needed
	if not dizzy_victim:
		saved_victim = null
		return
	
	if dizzy_victim.instability_component.full_instability_from_parry:
		can_kill_victim = readied_finisher or _player_within_finisher_distance()
	else:
		can_kill_victim = _player_within_finisher_distance()


func _player_within_finisher_distance() -> bool:
	return dizzy_victim\
		.entity\
		.global_position\
		.distance_to(player.global_position) <= finisher_distance

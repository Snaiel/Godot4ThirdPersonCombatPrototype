class_name DizzySystem
extends Node3D


var dizzy_victim: DizzyComponent:
	set(value):
		if dizzy_victim == value:
			return
		prev_victim = dizzy_victim
		dizzy_victim = value

var prev_victim: DizzyComponent

var can_kill_victim: bool = false
var victim_being_killed: bool = false
var dizzy_victim_killed: bool = false

@onready var player: Player = Globals.player


func _process(_delta):
	print(dizzy_victim)
	if not dizzy_victim:
		return
	
	if victim_being_killed:
		return
	
	if not dizzy_victim.instability_component.full_instability_from_parry and \
	dizzy_victim.entity.global_position.distance_to(player.global_position) > 1.2:
		can_kill_victim = false
	else:
		can_kill_victim = true

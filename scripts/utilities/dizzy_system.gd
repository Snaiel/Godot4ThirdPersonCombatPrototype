class_name DizzySystem
extends Node3D


var dizzy_victim: DizzyComponent
var can_kill_victim: bool = false
var dizzy_victim_killed: bool = false

@onready var player: Player = Globals.player


func _process(_delta):
	if not dizzy_victim:
		return
	
	if not dizzy_victim.instability_component.full_instability_from_parry and \
	dizzy_victim.entity.global_position.distance_to(player.global_position) > 1.2:
		can_kill_victim = false
	else:
		can_kill_victim = true

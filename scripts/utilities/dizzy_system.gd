class_name DizzySystem
extends Node3D


var dizzy_victim: DizzyComponent:
	set(value):
		if value != prev_victim:
			prev_victim = dizzy_victim
		dizzy_victim = value

var dizzy_victim_killed: bool = false

var prev_victim: DizzyComponent

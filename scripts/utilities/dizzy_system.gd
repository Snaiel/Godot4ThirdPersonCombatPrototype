class_name DizzySystem
extends Node3D


var dizzy_victim: DizzyComponent:
	set(value):
		if value != prev_victim:
			prev_victim = dizzy_victim
		dizzy_victim = value

var prev_victim: DizzyComponent


func _ready():
	Globals.dizzy_system = self

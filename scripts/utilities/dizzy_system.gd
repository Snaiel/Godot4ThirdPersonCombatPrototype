class_name DizzySystem
extends Node3D


var dizzy_victim: DizzyComponent


func _ready():
	Globals.dizzy_system = self


func _process(_delta):
	prints("dizzy victim:", dizzy_victim)

class_name PlayerHealthCharges
extends Control


@export var flask_color: Color = Color("8aff15")
@export var no_charges_color: Color = Color("556744")

@onready var label: Label = $Label
@onready var flask: Sprite2D = $Flask
@onready var player: Player = Globals.player


func _process(_delta):
	var charges_num: int = player.health_charge_component.current_charges
	label.text = String.num_int64(
		charges_num
	)
	
	if charges_num == 0:
		flask.self_modulate = no_charges_color
	else:
		flask.self_modulate = flask_color

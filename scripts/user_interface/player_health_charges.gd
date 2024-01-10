class_name PlayerHealthCharges
extends Control


@onready var label: Label = $Label
@onready var player: Player = Globals.player


func _process(delta):
	label.text = String.num_int64(
		player.health_charge_component.current_charges
	)

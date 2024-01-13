class_name UserInterface
extends Control


@onready var hud: HeadsUpDisplay = $HUD
@onready var checkpoint_interface: Control = $CheckpointInterface


func _ready():
	Globals.debug_label = $DebugLabel

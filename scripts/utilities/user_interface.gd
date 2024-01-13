class_name UserInterface
extends Control


@onready var hud: HeadsUpDisplay = $HUD

func _ready():
	Globals.debug_label = $DebugLabel

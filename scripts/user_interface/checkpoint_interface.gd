class_name CheckpointInterface
extends Control


@export var enabled: bool = false

@onready var recover_button: Button = $Buttons/Recover
@onready var return_button: Button = $Buttons/Return


func _ready():
	modulate.a = 0.0
	visible = false


func _physics_process(_delta):
	
	if enabled:
		modulate.a = lerp(
			modulate.a,
			1.0,
			0.1
		)
	else:
		modulate.a = lerp(
			modulate.a,
			0.0,
			0.1
		)

class_name CheckpointInterface
extends Control


@export var enabled: bool = false


func _ready():
	modulate.a = 0.0


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
	
	if is_zero_approx(modulate.a):
		visible = false
	else:
		visible = true

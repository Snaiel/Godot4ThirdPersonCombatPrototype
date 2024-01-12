class_name InteractionHints
extends Control


var counter: int


func _physics_process(_delta):
	if counter > 0:
		modulate.a = lerp(
			modulate.a,
			1.0,
			0.25
		)
	else:
		modulate.a = lerp(
			modulate.a,
			0.0,
			0.25
		)

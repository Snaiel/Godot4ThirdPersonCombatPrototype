class_name Crosshair
extends Sprite3D


@export var enabled: bool = true
@export var debug: bool = false
@export var show_crosshair: bool = false

var callbacks: Array[Callable]


func _ready() -> void:
	modulate.a = 0.0


func _physics_process(_delta: float) -> void:
	if not enabled:
		return
	
	show_crosshair = false
	
	for callback in callbacks:
		if bool(callback.call()) == true:
			show_crosshair = true
			break
	
	#if debug:
		#prints(
			#show_crosshair,
			#modulate.a,
			#visible
		#)
	
	if show_crosshair and modulate.a < 1.0:
		modulate.a = move_toward(
			modulate.a,
			1.0,
			0.05
		)
	elif not show_crosshair and modulate.a > 0.0:
		modulate.a = move_toward(
			modulate.a,
			0.0,
			0.05
		)


func register_callback(callback: Callable) -> void:
	callbacks.append(callback)

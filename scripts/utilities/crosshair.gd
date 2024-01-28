class_name Crosshair
extends Sprite3D


@export var enabled: bool = true
@export var show_crosshair: bool = false
@export var backstab_component: BackstabComponent
@export var dizzy_component: DizzyComponent

@onready var _backstab_system: BackstabSystem = Globals.backstab_system
@onready var _dizzy_system: DizzySystem = Globals.dizzy_system


func _ready() -> void:
	modulate.a = 0.0


func _physics_process(_delta: float) -> void:
	if not enabled:
		return
	
	show_crosshair = false
	
	if _backstab_system.backstab_victim != null and \
	_backstab_system.backstab_victim == backstab_component:
		show_crosshair = true
	
	if _dizzy_system.dizzy_victim != null and \
	_dizzy_system.dizzy_victim == dizzy_component:
		show_crosshair = true
	
	if show_crosshair:
		modulate.a = move_toward(
			modulate.a,
			1.0,
			0.05
		)
	else:
		modulate.a = move_toward(
			modulate.a,
			0.0,
			0.05
		)

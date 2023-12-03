class_name UserInterface
extends Control


var _lock_on_target: LockOnComponent = null
var _backstab_victim: Node3D = null
var _backstab_crosshair_visible: bool = false

@onready var _lock_on_texture: TextureRect = $LockOn
@onready var _crosshair: Sprite2D = $Crosshair


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_lock_on_texture.visible = false
	Globals.user_interface = self
	Globals.debug_label = $DebugLabel
	_crosshair.modulate.a = 0.0
	

func _process(_delta: float) -> void:
	_process_lock_on()
	_process_backstab()
		
	_lock_on_texture.visible = _lock_on_target != null


func _on_lock_on_system_lock_on(target: LockOnComponent) -> void:
	_lock_on_target = target


func _process_lock_on() -> void:
	if not _lock_on_target:
		return
	
	var pos: Vector2 = Globals.camera_controller.get_lock_on_position(_lock_on_target)
	var lock_on_pos: Vector2 = Vector2(
		pos.x - _lock_on_texture.size.x / 2,
		pos.y - _lock_on_texture.size.y / 2
	)
	
	_lock_on_texture.position = lock_on_pos


func _process_backstab() -> void:
	if not _backstab_victim:
		return
	
	var pos: Vector2 = Globals.camera_controller.get_lock_on_position(_backstab_victim)
	var crosshair_pos: Vector2 = Vector2(
		pos.x,
		pos.y
	)
	
	_crosshair.position = crosshair_pos
	
	if _backstab_crosshair_visible:
		_crosshair.modulate.a = lerp(
			_crosshair.modulate.a,
			1.0,
			0.2
		)
	else:
		_crosshair.modulate.a = lerp(
			_crosshair.modulate.a,
			0.0,
			0.2
		)


func set_backstab_visible(victim: Node3D, flag: bool) -> void:
	if victim:
		_backstab_victim = victim
	_backstab_crosshair_visible = flag
	

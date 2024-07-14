class_name HeadsUpDisplay
extends Control


@export var enabled: bool = true

var _lock_on_target: LockOnComponent = null

@onready var notice_triangles: Node2D = $NoticeTriangles
@onready var off_camera_notice_triangles: Control = $OffCameraNoticeTriangles
@onready var wellbeing_widgets: Node2D = $WellbeingWidgets
@onready var interaction_hints: InteractionHints = $InteractionHints
@onready var instability_bar: PlayerInstabilityBar = $PlayerInstabilityBar

@onready var _lock_on_texture: TextureRect = $LockOn

@onready var lock_on_system: LockOnSystem = Globals.lock_on_system
@onready var backstab_system: BackstabSystem = Globals.backstab_system
@onready var dizzy_system: DizzySystem = Globals.dizzy_system


func _ready() -> void:
	_lock_on_texture.visible = false
	
	lock_on_system.lock_on.connect(
		_on_lock_on_system_lock_on
	)


func _physics_process(_delta: float) -> void:
	
	_process_lock_on()
	
	_lock_on_texture.visible = _lock_on_target != null
	
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


func _on_lock_on_system_lock_on(target: LockOnComponent) -> void:
	_lock_on_target = target


func _process_lock_on() -> void:
	if not _lock_on_target: return
	
	var pos: Vector2 = Globals.camera_controller.get_lock_on_position(
		_lock_on_target
	)
	var lock_on_pos: Vector2 = Vector2(
		pos.x - _lock_on_texture.size.x / 2,
		pos.y - _lock_on_texture.size.y / 2
	)
	
	_lock_on_texture.position = lock_on_pos


func clear_enemy_hud_elements() -> void:
	for child in notice_triangles.get_children():
		child.queue_free()
	
	for child in wellbeing_widgets.get_children():
		child.queue_free()
	
	for child in off_camera_notice_triangles.get_children():
		child.queue_free()

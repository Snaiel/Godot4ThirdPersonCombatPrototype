class_name WellbeingComponent
extends Node3D


@export_category("Configuration")
@export var lock_on_component: LockOnComponent

@export_category("Health Bar")
@export var health_bar_scene: PackedScene

var default_health: float

var _default_health_sprite_scale_x: float
var _health_bar_sprite: Node2D
var _health_sprite: Sprite2D

var _show_health_bar_timer: Timer
var _show_health_bar_interval: float = 5.0

var _visible: bool = false

@onready var _camera: Camera3D = Globals.camera_controller.cam
@onready var _lock_on_system: LockOnSystem = Globals.lock_on_system


func _ready():
	_health_bar_sprite = health_bar_scene.instantiate()
	Globals.user_interface.health_bars.add_child(_health_bar_sprite)
	_health_sprite = _health_bar_sprite.get_node("Health")
	_default_health_sprite_scale_x = _health_sprite.scale.x
	
	_show_health_bar_timer = Timer.new()
	_show_health_bar_timer.wait_time = _show_health_bar_interval
	_show_health_bar_timer.autostart = false
	_show_health_bar_timer.one_shot = true
	_show_health_bar_timer.timeout.connect(
		func():
			if _lock_on_system.target != lock_on_component:
				_visible = false
	)
	add_child(_show_health_bar_timer)


func process_health(health: float) -> void:
	if _lock_on_system.target == lock_on_component or \
		not _show_health_bar_timer.is_stopped():
		_visible = true
	else:
		_visible = false
		
	if not _camera.is_position_in_frustum(global_position):
		_visible = false
	_health_bar_sprite.visible = _visible
	
	_health_bar_sprite.position = _camera.unproject_position(global_position)
	_health_sprite.scale.x = lerp(
		0.0, 
		_default_health_sprite_scale_x,
		health / default_health
	)


func show_health_bar() -> void:
	_visible = true
	_show_health_bar_timer.start()

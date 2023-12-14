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
var _delay_sprite: Sprite2D

var _show_health_bar_timer: Timer
var _show_health_bar_interval: float = 5.0
var _on_death_interval: float = 2.0

var _health_delay_timer: Timer
var _health_delay_pause: float = 0.8
var _play_delay: bool = false

var _visible: bool = false

@onready var _camera: Camera3D = Globals.camera_controller.cam
@onready var _lock_on_system: LockOnSystem = Globals.lock_on_system


func _ready():
	_health_bar_sprite = health_bar_scene.instantiate()
	Globals.user_interface.health_bars.add_child(_health_bar_sprite)
	_health_sprite = _health_bar_sprite.get_node("Health")
	_default_health_sprite_scale_x = _health_sprite.scale.x
	_delay_sprite = _health_bar_sprite.get_node("DelayBar")
	
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
	
	_health_delay_timer = Timer.new()
	_health_delay_timer.wait_time = _health_delay_pause
	_health_delay_timer.autostart = false
	_health_delay_timer.one_shot = true
	_health_delay_timer.timeout.connect(
		func():
			_play_delay = true
	)
	add_child(_health_delay_timer)


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
	
	if _play_delay:
		_delay_sprite.scale.x = move_toward(
			float(_delay_sprite.scale.x),
			_health_sprite.scale.x,
			0.005
		)
	
	if is_equal_approx(_delay_sprite.scale.x, _health_sprite.scale.x):
		_play_delay = false


func show_health_bar(health: float) -> void:
	_visible = true
	
	if health <= 0:
		_show_health_bar_timer.start(_on_death_interval)		
	else:
		_show_health_bar_timer.start()
		
	if _health_delay_timer.is_stopped():
		_health_delay_timer.start()

class_name NPCHealthBar
extends Node2D


var default_health: float
var health_bar_visible: bool = false

var _default_health_sprite_scale_x: float

var _show_health_bar_timer: Timer
var _show_health_bar_interval: float = 5.0

var _health_delay_timer: Timer
var _health_delay_pause: float = 0.8
var _play_delay: bool = false

@onready var _health_sprite: Sprite2D = $Health
@onready var _delay_sprite: Sprite2D = $DelayBar


func _ready():
	_default_health_sprite_scale_x = _health_sprite.scale.x
	
	_show_health_bar_timer = Timer.new()
	_show_health_bar_timer.wait_time = _show_health_bar_interval
	_show_health_bar_timer.autostart = false
	_show_health_bar_timer.one_shot = true
	_show_health_bar_timer.timeout.connect(
		func():
			health_bar_visible = false
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
		if is_zero_approx(health):
			health_bar_visible = false


func show_health_bar(_health: float) -> void:
	health_bar_visible = true
	
	_show_health_bar_timer.start()
		
	if _health_delay_timer.is_stopped():
		_health_delay_timer.start()

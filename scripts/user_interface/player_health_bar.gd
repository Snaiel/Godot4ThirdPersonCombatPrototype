class_name PlayerHealthBar
extends Control


var _health: float
var _default_health: float

var _default_health_scale_x: float

var _health_delay_timer: Timer
var _health_delay_pause: float = 0.8
var _play_delay: bool = false

var _default_background_length: float = 100.0

@onready var _background: Polygon2D = $Background
@onready var _health_bar: Polygon2D = $Health
@onready var _delay_bar: Polygon2D = $DelayBar

@onready var _player: Player = Globals.player


func _ready():
	
	_default_health = _player.health_component.max_health
	_default_health_scale_x = _default_health / 100.0
	
	# this extends the health bar depending the player's max health
	_background.polygon[2].x = _default_background_length * _default_health_scale_x
	_background.polygon[3].x = _default_background_length * _default_health_scale_x
	_health_bar.polygon[2].x = (_default_background_length * _default_health_scale_x) - 8.0
	_health_bar.polygon[3].x = (_default_background_length * _default_health_scale_x) - 8.0
	_delay_bar.polygon[2].x = (_default_background_length * _default_health_scale_x) - 8.0
	_delay_bar.polygon[3].x = (_default_background_length * _default_health_scale_x) - 8.0
	
	_player.health_component.took_damage.connect(
		func():
			if _health_delay_timer.is_stopped():
				_health_delay_timer.start()
	)
	
	_health_delay_timer = Timer.new()
	_health_delay_timer.wait_time = _health_delay_pause
	_health_delay_timer.autostart = false
	_health_delay_timer.one_shot = true
	_health_delay_timer.timeout.connect(
		func():
			_play_delay = true
	)
	add_child(_health_delay_timer)


func _process(_delta):
	
	_health = _player.health_component.health
	
	_health_bar.scale.x = lerp(
		0.0, 
		1.0,
		_health / _default_health
	)
	
	if _play_delay:
		_delay_bar.scale.x = move_toward(
			float(_delay_bar.scale.x),
			_health_bar.scale.x,
			0.005
		)
	
	if is_equal_approx(_delay_bar.scale.x, _health_bar.scale.x):
		_play_delay = false

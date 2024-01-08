class_name PlayerInstabilityBar
extends Control


@export var color_gradient: Gradient

var instability_bar_visible: bool = false

var _instability: float
var _max_instability: float

var _default_instability_scale_x: float

var _disappear_pause_timer: Timer
var _disappear_pause_length: float = 0.5

@onready var _instability_bar: Node2D = $Instability
@onready var _glare: Node2D = $Glare

@onready var _player: Player = Globals.player


func _ready():
	visible = false
	
	_default_instability_scale_x = _instability_bar.scale.x
	_max_instability = _player.instability_component.max_instability
	
	_disappear_pause_timer = Timer.new()
	_disappear_pause_timer.wait_time = _disappear_pause_length
	_disappear_pause_timer.autostart = false
	_disappear_pause_timer.one_shot = true
	_disappear_pause_timer.timeout.connect(
		func():
			visible = false
	)
	add_child(_disappear_pause_timer)

func _process(_delta):
	_instability = _player.instability_component.instability
	
	if _instability > 0:
		visible = true
	elif _disappear_pause_timer.is_stopped():
		_disappear_pause_timer.start()
	
	var instability_percentage = _instability / _max_instability
	
	if is_zero_approx(instability_percentage):
		instability_bar_visible = false
	
	_instability_bar.scale.x = lerp(
		0.0, 
		_default_instability_scale_x,
		instability_percentage
	)
	
	_instability_bar.self_modulate = color_gradient.sample(instability_percentage)
	
	if is_equal_approx(instability_percentage, 1.0):
		_glare.visible = true
	else:
		_glare.visible = false

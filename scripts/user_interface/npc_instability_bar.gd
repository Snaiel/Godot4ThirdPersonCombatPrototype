class_name NPCInstabilityBar
extends Node2D


@export var color_gradient: Gradient

var current_instability: float
var max_instability: float
var should_be_visible: bool = false

var _default_instability_sprite_scale_x: float

@onready var instability_bar: Node2D = $Instability
@onready var glare: Node2D = $Glare


func _ready():
	_default_instability_sprite_scale_x = instability_bar.scale.x


func _process(_delta: float) -> void:
	var instability_percentage = current_instability / max_instability
	
	if is_zero_approx(instability_percentage):
		should_be_visible = false
	
	instability_bar.scale.x = lerp(
		0.0, 
		_default_instability_sprite_scale_x,
		instability_percentage
	)
	
	instability_bar.self_modulate = color_gradient.sample(instability_percentage)
	
	if is_equal_approx(instability_percentage, 1.0):
		glare.visible = true
	else:
		glare.visible = false


func instability_increased(_instability: float) -> void:
	should_be_visible = true

class_name NPCInstabilityBar
extends Node2D


var max_instability: float
var instability_bar_visible: bool = false

var _default_instability_sprite_scale_x: float

@onready var instability_bar: Node2D = $Instability


func _ready():
	_default_instability_sprite_scale_x = instability_bar.scale.x


func process_instability(instability: float) -> void:
	instability_bar.scale.x = lerp(
		0.0, 
		_default_instability_sprite_scale_x,
		instability / max_instability
	)


func change_instability(instability: float) -> void:
	print(
		lerp(
			0.0, 
			_default_instability_sprite_scale_x,
			instability / max_instability
		)
	)

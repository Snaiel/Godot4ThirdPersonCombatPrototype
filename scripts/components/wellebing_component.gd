class_name WellbeingComponent
extends Node3D


@export_category("Health Bar")
@export var health_bar_scene: PackedScene

var default_health: float

var _default_health_sprite_scale_x: float
var _health_bar_sprite: Node2D
var _health_sprite: Sprite2D

@onready var _camera: Camera3D = Globals.camera_controller.cam


func _ready():
	_health_bar_sprite = health_bar_scene.instantiate()
	Globals.user_interface.health_bars.add_child(_health_bar_sprite)
	_health_sprite = _health_bar_sprite.get_node("Health")
	_default_health_sprite_scale_x = _health_sprite.scale.x


func process_health(health: float) -> void:
	_health_bar_sprite.visible = _camera.is_position_in_frustum(global_position)
	_health_bar_sprite.position = _camera.unproject_position(global_position)
	_health_sprite.scale.x = lerp(
		0.0, 
		_default_health_sprite_scale_x,
		health / default_health
	)

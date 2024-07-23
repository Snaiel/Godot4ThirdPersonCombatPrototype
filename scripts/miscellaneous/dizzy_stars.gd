class_name DizzyStars
extends Node3D


@export var enabled: bool = false:
	set(value):
		if value == enabled: return
		visible = value
		_set_stars_trail_enabled(value)
		enabled = value

@export var speed: float = 360

@onready var stars: Node3D = $Stars


func _ready() -> void:
	visible = enabled
	_set_stars_trail_enabled(enabled)


func _process(delta: float) -> void:
	var r: float = stars.rotation_degrees.y
	stars.rotation_degrees.y = wrapf(
		r + speed * delta,
		0.0,
		360
	)
	
	var count: int = stars.get_child_count()
	for i in count:
		stars.get_child(i).position.y = 0.1 * sin(
			2 * deg_to_rad(r + (i * (360 / float(count))))
		)


func _set_stars_trail_enabled(_enabled: bool) -> void:
	for node in stars.get_children():
		node.get_node("Trail").trail_enabled = _enabled

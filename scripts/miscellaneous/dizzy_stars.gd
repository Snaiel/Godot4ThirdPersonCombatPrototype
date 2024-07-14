class_name DizzyStars
extends Node3D


@export var speed: float = 360

@onready var stars: Node3D = $Stars


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

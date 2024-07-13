class_name DizzyStars
extends Node3D


@export var speed: float = 360


func _process(delta: float) -> void:
	$Stars.rotation_degrees.y = wrapf(
		$Stars.rotation_degrees.y + speed * delta,
		0.0,
		360
	)

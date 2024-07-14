class_name Projectile
extends DamageSource


@export var speed: float = 2

var direction: Vector3 = Vector3.FORWARD

@onready var area: Area3D = $Area 


func _ready():
	get_tree().create_timer(10.0).timeout.connect(queue_free)


func _process(delta: float) -> void:
	position += direction * speed * delta


func hit_considered() -> bool:
	queue_free()
	return true

class_name Projectile
extends DamageSource


@export var speed: float = 2

var direction: Vector3 = Vector3.FORWARD

@onready var area: Area3D = $Area 


func _ready():
	get_tree().create_timer(10.0).timeout.connect(queue_free)
	area.body_entered.connect(
		func(body: Node3D):
			if not body is StaticBody3D: return
			var static_body: StaticBody3D = body
			var layers: String = String.num_uint64(
				static_body.collision_layer,
				2
			)
			if not layers.ends_with("1"): return
			queue_free()
	)


func _process(delta: float) -> void:
	position += direction * speed * delta


func hit_considered() -> bool:
	queue_free()
	return true

class_name Projectile
extends DamageSource


@export var speed: float = 2

var direction: Vector3 = Vector3.FORWARD

@onready var area: Area3D = $Area 


func _ready():
	area.body_entered.connect(
		func(body: Node) -> void:
			if body == entity: return
			#queue_free()
	)

func _process(delta: float) -> void:
	position += direction * speed * delta


func hit_considered() -> bool:
	queue_free()
	return true

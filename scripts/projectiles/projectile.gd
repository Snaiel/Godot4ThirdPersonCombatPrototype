class_name Projectile
extends Area3D


@export var speed: float = 2

var entity: Node
var direction: Vector3 = Vector3.FORWARD


func _ready():
	body_entered.connect(
		func(body: Node) -> void:
			if body == entity: return
			queue_free()
	)

func _process(delta: float) -> void:
	position += direction * speed * delta

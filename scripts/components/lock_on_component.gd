class_name LockOnComponent
extends Area3D

signal destroyed(target: LockOnComponent)

@export var health_component: HealthComponent

func _ready() -> void:
	if health_component:
		health_component.zero_health.connect(_emit_destroyed)


func _emit_destroyed() -> void:
	destroyed.emit(self)

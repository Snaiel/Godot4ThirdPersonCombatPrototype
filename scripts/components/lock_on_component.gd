class_name LockOnComponent
extends Area3D


signal destroyed(target: LockOnComponent)

@export var enabled: bool = true
@export var component_owner: Node3D
@export var bone_attachment: Node3D
@export var health_component: HealthComponent


func _ready() -> void:
	if health_component:
		health_component.zero_health.connect(_emit_destroyed)


func _process(_delta):
	if bone_attachment:
		global_position = bone_attachment.global_position


func _emit_destroyed() -> void:
	destroyed.emit(self)

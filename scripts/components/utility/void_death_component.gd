class_name VoidDeathComponent
extends Node


@export var entity: CharacterBody3D
@export var health_component: HealthComponent


func _ready() -> void:
	Globals.void_death_system.fallen_into_the_void.connect(
		func(body: Node3D):
			if body != self:
				return
			health_component.deal_max_damage = true
			health_component.decrement_health(1)
			var timer: SceneTreeTimer = get_tree().create_timer(5)
			timer.timeout.connect(entity.queue_free)
	)

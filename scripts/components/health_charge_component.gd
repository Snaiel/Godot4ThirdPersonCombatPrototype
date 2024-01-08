class_name HealthChargeComponent
extends Node3D


signal finished_drinking


@export var character: CharacterAnimations
@export var health_component: HealthComponent
@export var recovery_amount: float = 60.0


func _ready():
	character.drink_animations.gain_health.connect(
		func():
			health_component.health += recovery_amount
	)
	
	character.drink_animations.finished.connect(
		func():
			finished_drinking.emit()
	)


func consume_health_charge() -> void:
	character.drink_animations.drink()

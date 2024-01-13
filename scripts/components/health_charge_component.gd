class_name HealthChargeComponent
extends Node3D


signal finished_drinking

@export var entity: CharacterBody3D
@export var character: CharacterAnimations
@export var health_component: HealthComponent
@export var recovery_amount: float = 60.0
@export var max_charges: int = 8

var current_charges: int = max_charges:
	set(value):
		current_charges = clampi(value, 0, max_charges)

var _show_light: bool = false
var _desired_light_energy: float

@onready var particles: Array[GPUParticles3D] = [
	$GreenSpeckles,
	$BlueSpeckles,
	$Chevrons
]
@onready var lights: Array[OmniLight3D] = [
	$OmniLight3D,
	$OmniLight3D2
]


func _ready():
	_desired_light_energy = lights[0].light_energy
	
	for light in lights:
			light.light_energy = 0.0
	
	character.drink_animations.gain_health.connect(
		func():
			if current_charges == 0:
				return
			
			current_charges -= 1
			health_component.health += recovery_amount
			for particle in particles:
				particle.restart()
			_show_light = true
	)
	
	character.drink_animations.finished.connect(
		func():
			finished_drinking.emit()
			_show_light = false
	)


func _physics_process(_delta):
	if _show_light:
		for light in lights:
			light.light_energy = lerp(
				light.light_energy,
				_desired_light_energy,
				0.05
			)
	else:
		for light in lights:
			light.light_energy = lerp(
				light.light_energy,
				0.0,
				0.05
			)


func consume_health_charge() -> void:
	character.drink_animations.drink()
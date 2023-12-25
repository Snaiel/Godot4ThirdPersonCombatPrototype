class_name CameraControllerDizzyFinisherState
extends CameraControllerStateMachine


@export var from_parry: CameraControllerDizzyFinisherFromParryState
@export var from_damage: CameraControllerDizzyFinisherFromDamageState

@onready var dizzy_system: DizzySystem = Globals.dizzy_system


func _ready():
	super._ready()


func enter():
	var state: CameraControllerStateMachine
	if dizzy_system.dizzy_victim.instability_component.full_instability_from_parry:
		state = from_parry
	else:
		state = from_damage
	
	if current_state != state:
		change_state(state)


func process_camera():
	pass


func process_unhandled_input(_event: InputEvent):
	pass


func exit():
	pass


# meta-name: Camera Controller State
# meta-default: true
# meta-space-indent: 4

class_name CameraControllersState
extends CameraControllerStateMachine


func _ready():
	super._ready()


func enter() -> void:
	pass


func process_camera() -> void:
	pass


func process_unhandled_input(_event: InputEvent) -> void:
	pass


func exit() -> void:
	pass

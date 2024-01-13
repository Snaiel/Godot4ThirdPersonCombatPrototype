class_name PlayerCheckpointState
extends PlayerStateMachine


@onready var user_interface: UserInterface = Globals.user_interface
@onready var camera_controller: CameraController = Globals.camera_controller
@onready var lock_on_system: LockOnSystem = Globals.lock_on_system


func _ready():
	super._ready()
	
	player.character.sitting_animations.finished.connect(
		func():
			parent_state.transition_to_default_state()
	)


func enter():
	player.rotation_component.can_rotate = false
	player.character.sitting_animations.sit_down()
	player.set_root_motion(true)
	player.checkpoint_system.disable_hint()
	user_interface.hud.visible = false
	camera_controller.enabled = false
	lock_on_system.enabled = false


func process_player():
	if Input.is_action_just_pressed("interact") and \
	player.character.sitting_animations.sitting_idle:
		player.character.sitting_animations.stand_up()


func process_movement_animations() -> void:
	player.character.movement_animations.move(
		Vector3.ZERO,
		player.lock_on_target != null, 
		false
	)


func exit():
	player.set_root_motion(false)
	player.rotation_component.can_rotate = true
	player.checkpoint_system.enable_hint()
	user_interface.hud.visible = true
	camera_controller.enabled = true
	lock_on_system.enabled = true

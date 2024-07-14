class_name PlayerCheckpointState
extends PlayerStateMachine


var _exiting: bool = false

@onready var user_interface: UserInterface = Globals.user_interface
@onready var camera_controller: CameraController = Globals.camera_controller
@onready var lock_on_system: LockOnSystem = Globals.lock_on_system
@onready var checkpoint_system: CheckpointSystem = Globals.checkpoint_system


func _ready():
	super()
	
	player.character.sit_animations.sat_down.connect(
		func():
			if parent_state.current_state == self:
				user_interface.checkpoint_interface.show_menu()
	)
	
	player.character.sit_animations.finished.connect(
		func():
			if parent_state.current_state == self:
				parent_state.transition_to_default_state()
	)
	
	user_interface.checkpoint_interface.exit_checkpoint.connect(
		_stand_up
	)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and \
	not parent_state.current_state is PlayerDeathState and \
	parent_state.current_state != self and \
	checkpoint_system.current_checkpoint and \
	checkpoint_system.current_checkpoint.can_sit_at_checkpoint:
		parent_state.change_state(self)


func enter() -> void:
	_exiting = false
	
	player.character.sit_animations.sit_down()
	player.locomotion_component.set_active_strategy("root_motion")
	player.hitbox_component.enabled = false
	player.rotation_component.target = checkpoint_system.current_checkpoint
	
	player.rotation_component.rotate_towards_target = true
	Globals.lock_on_system.reset_target()
	
	
	checkpoint_system.disable_hint()
	checkpoint_system.save_current_checkpoint()
	
	user_interface.hud.enabled = false


func process_player() -> void:
	pass


func process_movement_animations() -> void:
	player.character.idle_animations.active = player.lock_on_target != null
	player.character.movement_animations.dir = Vector3.ZERO


func exit() -> void:
	player.locomotion_component.set_active_strategy("programmatic")
	player.rotation_component.can_rotate = true
	player.hitbox_component.enabled = true
	
	checkpoint_system.enable_hint()
	
	user_interface.hud.enabled = true
	user_interface.checkpoint_interface.visible = false
	
	player.rotation_component.rotate_towards_target = false
	player.rotation_component.target = null
	


func _stand_up() -> void:
	player.character.sit_animations.stand_up()
	user_interface.checkpoint_interface.hide_menu()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_exiting = true

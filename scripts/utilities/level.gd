class_name Level
extends Node3D


@export var player: Player
@export var user_interface: UserInterface
@export var camera_controller: CameraController
@export var lock_on_system: LockOnSystem
@export var backstab_system: BackstabSystem
@export var dizzy_system: DizzySystem
@export var checkpoint_system: CheckpointSystem


func _enter_tree():
	Globals.backstab_system = backstab_system
	Globals.dizzy_system = dizzy_system
	Globals.lock_on_system = lock_on_system
	Globals.camera_controller = camera_controller
	Globals.player = player
	Globals.user_interface = user_interface
	Globals.checkpoint_system = checkpoint_system

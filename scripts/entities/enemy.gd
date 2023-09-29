class_name Enemy
extends CharacterBody3D

signal death(enemy)

@export var debug: bool = false

@export var friction: float = 0.05

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _blackboard: Blackboard = $Blackboard
@onready var _player: Player = Globals.player
@onready var _rotation_component: RotationComponent = $RotationComponent


func _ready() -> void:
	_rotation_component.target = _player


func _physics_process(delta: float) -> void:

	var player_dist: float = global_position.distance_to(_player.global_position)
	var player_dir: Vector3 = global_position.direction_to(_player.global_position)
	var player_dir_angle: float = player_dir.angle_to(Vector3.BACK.rotated(Vector3.UP, global_rotation.y))

	_blackboard.set_value("target", _player)
	_blackboard.set_value("target_dist", player_dist)
	_blackboard.set_value("target_dir", player_dir)
	_blackboard.set_value("target_dir_angle", player_dir_angle)

	if debug:
		print(_rotation_component.look_at_target)

	_rotation_component.look_at_target = _blackboard.get_value("look_at_target", false)

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	velocity.x = lerp(velocity.x, 0.0, friction)
	velocity.z = lerp(velocity.z, 0.0, friction)

	move_and_slide()

func get_hit(knockback: float) -> void:
	var player = Globals.player
	velocity = player.position.direction_to(position) * knockback

func _on_entity_hitbox_weapon_hit(weapon: Sword) -> void:
	get_hit(weapon.knockback)


func _on_health_component_zero_health() -> void:
	death.emit(self)
	queue_free()

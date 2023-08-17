class_name Enemy
extends CharacterBody3D

signal death(enemy)

@export var friction = 0.05

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _blackboard: Blackboard = $Blackboard 
@onready var _player: Player = Globals.player

func _physics_process(delta):
	
	var player_dist = global_position.distance_to(_player.global_position)
	var player_dir = global_position.direction_to(_player.global_position)
	var player_dir_angle = player_dir.angle_to(Vector3.BACK)
	
	_blackboard.set_value("player_dist", player_dist)
	_blackboard.set_value("player_dir", player_dir)
	_blackboard.set_value("player_dir_angle", player_dir_angle)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	velocity.x = lerp(velocity.x, 0.0, friction)
	velocity.z = lerp(velocity.z, 0.0, friction)	

	move_and_slide()

func get_hit(knockback):
	var player = Globals.player
	velocity = player.position.direction_to(position) * knockback

func _on_entity_hitbox_weapon_hit(weapon: Sword):
	get_hit(weapon.knockback)


func _on_health_component_zero_health():
	death.emit(self)
	queue_free()

class_name Enemy
extends CharacterBody3D

var _knockback_resistance = 5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if abs(velocity.x) > 0:
		velocity.x -= sign(velocity.x) *  _knockback_resistance * delta
	if abs(velocity.z) > 0:
		velocity.z -= sign(velocity.z) * _knockback_resistance * delta

	move_and_slide()

func get_hit():
	var player = Globals.player
	velocity = (position - player.position).normalized() * 2

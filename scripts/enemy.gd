class_name Enemy
extends CharacterBody3D

@export var friction = 0.05

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	velocity.x = lerp(velocity.x, 0.0, friction)
	velocity.z = lerp(velocity.z, 0.0, friction)	

	move_and_slide()

func get_hit(knockback):
	var player = Globals.player
	velocity = player.position.direction_to(position) * knockback


func _on_entity_hitbox_weapon_hit(_damage, knockback):
	get_hit(knockback)

class_name EnemySection
extends Area3D


@onready var enemies: Node3D = $Enemies


func _ready():
	
	remove_child(enemies)
	
	body_entered.connect(
		func(_body: Node3D):
			print("Player entered enemy section: " + name)
			add_child(enemies)
			Globals.checkpoint_system.set_enemies_chldren_owner()
	)

	body_exited.connect(
		func(_body: Node3D):
			print("Player left enemy section: " + name)
			remove_child(enemies)
	)

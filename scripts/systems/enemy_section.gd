class_name EnemySection
extends Area3D


@onready var enemies: Node3D = $Enemies


func _ready():
	
	remove_child(enemies)
	
	body_entered.connect(
		func(_body: Node3D):
			print("Player entered enemy section: " + name)
			add_child(enemies)
			Globals.checkpoint_system.set_node_owner_to_enemies(
				enemies, enemies
			)
	)
	
	body_exited.connect(
		func(_body: Node3D):
			print("Player left enemy section: " + name)
			remove_child(enemies)
	)


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		print("DELETE")
		for node in enemies.get_children():
			var enemy: Enemy = node
			BeehaveDebuggerMessages.unregister_tree(enemy.beehave_tree.get_instance_id())

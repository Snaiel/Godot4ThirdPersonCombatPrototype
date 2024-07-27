class_name EnemySection
extends Area3D


@onready var enemies: Node3D = $Enemies
@onready var patrols: Node3D


func _ready():
	patrols = get_node_or_null("Patrols")
	
	remove_child(enemies)
	_set_patrols_enabled(false)
	
	body_entered.connect(
		func(_body: Node3D):
			print("Player entered enemy section: " + name)
			add_child(enemies)
			Globals.checkpoint_system.set_node_owner_to_enemies(
				enemies, enemies
			)
			_set_patrols_enabled(true)
	)
	
	body_exited.connect(
		func(_body: Node3D):
			print("Player left enemy section: " + name)
			remove_child(enemies)
			_set_patrols_enabled(false)
	)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		print("DELETE")
		for node in enemies.get_children():
			var enemy: Enemy = node
			BeehaveDebuggerMessages.unregister_tree(enemy.beehave_tree.get_instance_id())


func _set_patrols_enabled(enabled: bool) -> void:
	if not patrols: return
	if enabled:
		patrols.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		patrols.process_mode = Node.PROCESS_MODE_DISABLED

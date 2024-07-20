class_name VoidDeathSystem
extends Node


signal fallen_into_the_void(body: Node3D)


func _ready() -> void:
	var void_areas = get_tree().get_nodes_in_group("void_area")
	for node in void_areas:
		var area: Area3D = node
		area.body_entered.connect(
			func(body: Node3D):
				fallen_into_the_void.emit(body)
				prints("Fallen in to the void:", body)
		)

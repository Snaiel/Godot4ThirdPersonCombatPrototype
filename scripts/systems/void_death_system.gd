class_name VoidDeathSystem
extends Node3D


signal fallen_into_the_void(body: Node3D)


func _ready() -> void:
	for child in get_children():
		var area: Area3D = child
		area.body_entered.connect(
			func(body: Node3D):
				fallen_into_the_void.emit(body)
				prints("Fallen in to the void:", body)
		)

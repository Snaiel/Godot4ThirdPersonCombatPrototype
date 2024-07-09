extends PathFollow3D


enum PatrolType {LINEAR, OSCILLATE, CIRCUIT}


@export var patrol_type: PatrolType
@export var speed: float = 3

var direction: int = 1

func _ready():
	if patrol_type != PatrolType.CIRCUIT:
		loop = false


func _process(delta: float) -> void:
	match patrol_type:
		PatrolType.LINEAR:
			if progress_ratio < 1.0:
				progress += direction * speed * delta
		PatrolType.OSCILLATE:
			if direction == 1 and progress_ratio >= 1:
				direction = -1
			elif direction == -1 and progress_ratio <= 0:
				direction = 1
			progress += direction * speed * delta 
		PatrolType.CIRCUIT:
			progress += direction * speed * delta
	

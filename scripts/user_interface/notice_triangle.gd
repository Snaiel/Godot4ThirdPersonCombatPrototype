class_name NoticeTriangle
extends Sprite2D


var original_scale: Vector2

@onready var background_triangle: Sprite2D = $BackgroundTriangle
@onready var triangle_mask: Sprite2D = $TriangleMask
@onready var inner_triangle: Sprite2D = $TriangleMask/InsideTriangle


func _ready():
	original_scale = scale


func process_mask_offset(value: float) -> void:
	triangle_mask.offset.y = get_mask_offset(value)


func process_scale(expand_scale: float) -> void:
	scale = original_scale * Vector2(expand_scale, expand_scale)


func process_colour(colour: Color) -> void:
	self_modulate = lerp(
		self_modulate,
		colour,
		0.2
	)
	
	inner_triangle.self_modulate = lerp(
		inner_triangle.self_modulate,
		colour,
		0.2
	)


func process_alpha(alpha: float) -> void:
	modulate.a = lerp(
		modulate.a,
		alpha,
		0.1
	)


func get_mask_offset(value: float) -> float:
	return -62.0 * value + 80.0

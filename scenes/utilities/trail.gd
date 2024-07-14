class_name Trail3D
extends MeshInstance3D

"""
from https://www.youtube.com/watch?v=vKrrxKS-lcA
"""

@export var trail_enabled : bool = true

@export var _from_width : float = 0.5
@export var _to_width : float = 0.0
@export_range(0.5, 1.5) var _scale_acceleration : float = 1.0

@export var _motion_delta : float = 0.01
@export var _lifespan : float = 1.0

@export var _start_color : Color = Color(1.0, 1.0, 1.0, 1.0)
@export var _end_color : Color = Color(1.0, 1.0, 1.0, 0.0)

var _points = []
var _widths = []
var _life_points = []

var _old_pos : Vector3


func _ready() -> void:
	_old_pos = global_transform.origin
	mesh = ImmediateMesh.new()


func _process(delta):
	if trail_enabled and \
	(_old_pos - global_transform.origin).length() > _motion_delta:
		_append_point()
		_old_pos = global_transform.origin
	
	var p = 0
	var max_points = _points.size()
	while p < max_points:
		_life_points[p] += delta
		if _life_points[p] > _lifespan:
			_remove_point(p)
			max_points = _points.size()
		else:
			p += 1
	
	mesh.clear_surfaces()
	
	if _points.size() < 2:
		return

	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for i in range(_points.size()):
		var t = float(i) / (_points.size() - 1.0)
		var curr_color = _start_color.lerp(_end_color, 1 - t)
		mesh.surface_set_color(curr_color)
		
		var curr_width = _widths[i][0] \
			- pow(1 - t, _scale_acceleration) \
			* _widths[i][1]
		
		var t0 = i / float(_points.size())
		var t1 = t
		
		mesh.surface_set_uv(Vector2(t0, 0))
		mesh.surface_add_vertex(to_local(_points[i] + curr_width))
		mesh.surface_set_uv(Vector2(t1, 1))
		mesh.surface_add_vertex(to_local(_points[i] - curr_width))
	
	mesh.surface_end()


func _append_point() -> void:
	_points.append(global_transform.origin)
	_widths.append([
		global_transform.basis.x * _from_width,
		global_transform.basis.x * _from_width \
			- global_transform.basis.x * _to_width
	])
	_life_points.append(0.0)


func _remove_point(i: int) -> void:
	_points.remove_at(i)
	_widths.remove_at(i)
	_life_points.remove_at(i)

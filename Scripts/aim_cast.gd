class_name AimCast
extends ShapeCast2D

func _ready():
	enabled = false
	shape = CircleShape2D.new()
	set_collision_mask(2)
	pass
	
func get_colldiers(target_pos, radius):
	var res = []
	position = target_pos
	shape.radius = radius
	target_position = Vector2.ZERO
	force_shapecast_update()
	var collision_data = _get_collision_result()
	print(collision_data)
	for collision in collision_data:
		res.append(collision.collider.rid)

	return res

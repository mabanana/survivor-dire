extends ParallaxLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var child: Sprite2D
	if get_child_count() == 1:
		child = get_child(0)
	else:
		print("Cannot render parralax layer with more than 1 child")
	motion_mirroring = child.texture.get_size() * scale
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

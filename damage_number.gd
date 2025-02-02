extends Label
class_name DamageNumber

# Called when the node enters the scene tree for the first time.
func _ready():
	var new_pos = position + Vector2.UP.rotated(deg_to_rad(randf_range(-20,20))) * randf_range(20,70)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", new_pos, 0.6)
	tween.set_ease(Tween.EASE_OUT)
	await tween.finished
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

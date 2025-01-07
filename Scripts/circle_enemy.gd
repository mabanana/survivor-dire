class_name CircleEnemy
extends EnemyCharacter

# spawn new circles
func on_death():
	core.emit_changed(core.Context.circle_died, {
		CoreModel.PKey.target_rid : rid,
		core.PKey.target_position : position,
	})
	collision_shape.disabled = true

extends GameCharacter

func _physics_process(delta: float) -> void:
	var direction = (core.stats.player_pos - position).normalized()
	if direction:
		velocity = direction * core.scene.entities[rid].speed

	move_and_slide()

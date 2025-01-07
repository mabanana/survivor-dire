class_name SmallCircleEnemy
extends EnemyCharacter

var parent_circle_rid: int

func _physics_process(delta: float) -> void:
	var direction = (core.scene.player_pos - position).normalized()
	if direction and not dead and not parent_circle_rid in core.scene.entities:
		velocity = direction * core.scene.entities[rid].speed
		
		move_and_slide()

extends GameCharacter
var shader_progress: float = 0
var dead = false

func _physics_process(delta: float) -> void:
	var direction = (core.scene.player_pos - position).normalized()
	if direction and not dead:
		velocity = direction * core.scene.entities[rid].speed
		
		move_and_slide()

func die():
	queue_free()
	dead = true
	velocity = Vector2.ZERO
	$Sprite2D.material = ShaderMaterial.new()
	$Sprite2D.material.set("shader", load("res://Shaders/death_material.tres"))
	$Sprite2D.material.set("shader_parameter/progress", 1)
	

func _process(delta: float) -> void:
	if dead:
		$Sprite2D.material.set("shader_parameter/progress", shader_progress)
		shader_progress += delta * 1
		if shader_progress >= 1.5:
			queue_free()

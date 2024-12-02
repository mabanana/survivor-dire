extends GameCharacter
# TODO: REMOVE SIGNAL LISTENING
var shader_progress: float = 0.8
var dead = false

func _ready():
	material = ShaderMaterial.new()
	material.shader = load("res://Shaders/death_shader.gdshader")
	core_changed.disconnect(_on_core_changed)

func _physics_process(delta: float) -> void:
	var direction = (core.scene.player_pos - position).normalized()
	if direction and not dead:
		velocity = direction * core.scene.entities[rid].speed
		
		move_and_slide()

func die():
	dead = true
	velocity = Vector2.ZERO
	modulate.r += 0.5

func _process(delta: float) -> void:
	if dead:
		$Sprite2D.material.set("shader_parameter/progress", shader_progress)
		shader_progress += delta * 1
		if shader_progress >= 1.5:
			queue_free()

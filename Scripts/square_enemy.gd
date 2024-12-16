extends GameCharacter
# TODO: REMOVE SIGNAL LISTENING
var shader_progress: float = 0.8
var dead = false
@onready var hp_bar: ProgressBar = %ProgressBar

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
	hp_bar.visible = false
	velocity = Vector2.ZERO
	# 0 is left and measures degrees clockwise
	var angle = rad_to_deg(core.scene.player_pos.angle_to_point(position))
	if angle < 0:
		angle = 360 + angle
	#print("angle: ",angle)
	var quarters = int(angle/90)
	rotate(deg_to_rad(quarters*90 + 180))
	angle -= quarters * 90
	#prints("angle: rotate", quarters, "quarters then rotate", angle, "degrees",1 - angle/90.0 )
	$Sprite2D.material.set("shader_parameter/angle", 1 - angle/90.0)

func _process(delta: float) -> void:
	if dead:
		$Sprite2D.material.set("shader_parameter/progress", shader_progress)
		shader_progress += delta * 0.5
		if shader_progress >= 1.2:
			queue_free()

class_name EnemyCharacter
extends GameCharacter

var shader_progress: float = -0.1
var shader_speed: float = 1.5
var dead = false
@onready var hp_bar: ProgressBar = %HealthBar/ProgressBar
@onready var sprite: Sprite2D = %Sprite2D
@onready var collision_shape: CollisionShape2D = %CollisionShape2D

func _ready():
	# Set Shader Resource to be Local to Scene so progress is not shared between instances
	# TODO: Cache shader in an asset loader
	core_changed.disconnect(_on_core_changed)
	on_ready()

func on_ready():
	pass

func _physics_process(delta: float) -> void:
	var direction = (core.scene.player_pos - position).normalized()
	if direction and not dead:
		velocity = direction * core.scene.entities[rid].speed
		
		move_and_slide()

func die():
	on_death()
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
	sprite.material.set("shader_parameter/angle", 1 - angle/90.0)
	shader_progress = 0.2

func _process(delta: float) -> void:
	if dead:
		sprite.material.set("shader_parameter/progress", shader_progress)
		shader_progress += delta * shader_speed
		if shader_progress >= 1:
			queue_free()
			
func on_death():
	pass

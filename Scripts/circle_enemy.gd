class_name CircleEnemy
extends EnemyCharacter

func _ready():
	material = ShaderMaterial.new()
	# TODO: Cache shader in an asset loader
	material.shader = load("res://Shaders/death_shader.gdshader")
	_instantiate_collision_shape()
	_set_clip_mask_shape()
	core_changed.disconnect(_on_core_changed)

func _instantiate_collision_shape():
	collision_shape.shape = CircleShape2D.new()
	collision_shape.shape.radius = (sprite.get_rect().size * sprite.scale.x).x / 2
	add_child(collision_shape)

func _set_clip_mask_shape():
	%MeshInstance2D.mesh = SphereMesh.new()
	%MeshInstance2D.mesh.radius = (sprite.get_rect().size * sprite.scale.x).x / 2
	%MeshInstance2D.mesh.height = (sprite.get_rect().size * sprite.scale.x).x
	$MeshInstance2D.clip_children = 1

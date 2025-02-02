extends MeshInstance2D
class_name BulletMesh

var dest: Vector2
var dist: int
const speed: int = 2000

# Called when the node enters the scene tree for the first time.
func _ready():
	if not dest:
		queue_free()
		print("no destination on BulletMesh")
	dest = dest - position
	dist = dest.length()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += dest.normalized() * speed * delta
	dist -= speed * delta
	if dist <= 0:
		queue_free()

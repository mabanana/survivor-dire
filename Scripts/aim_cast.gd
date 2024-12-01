class_name AimCast
extends ShapeCast2D

var core: CoreModel
var core_changed: Signal

func bind(core, core_changed):
	self.core = core
	self.core_changed = core_changed
	
	core_changed.connect(_on_core_changed)
	
func _on_core_changed(context, payload):
	if context == CoreModel.Context.mouse_button_pressed:
		if payload[CoreModel.PKey.input_action] == InputHandler.PlayerActions.AIM_ATTACK:
			position = payload[CoreModel.PKey.mouse_position]
			force_shapecast_update()
			prints("collider results:",collision_result)

func _ready():
	enabled = false
	set_collision_mask(2)
	shape = CircleShape2D.new()
	shape.radius = 40
	target_position = Vector2(0,0)

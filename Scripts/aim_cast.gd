class_name AimCast

var core: CoreModel
var core_changed: Signal

func bind(core, core_changed):
	self.core = core
	self.core_changed = core_changed
	
	core_changed.connect(_on_core_changed)
	
func _on_core_changed(context, payload):
	if context == CoreModel.Context.mouse_button_pressed:
		if payload[CoreModel.PKey.input_action] == InputHandler.PlayerActions.AIM_ATTACK:
			var colliders = get_colldiers(payload[CoreModel.PKey.mouse_position], core.stats.spell_radius)
			prints("colliders:", colliders)
			

func get_colldiers(position, radius):
	var entities = core.scene.entities
	var res = []
	for rid in entities.keys():
		if entities[rid].entity_type != core.EntityType.player:
			var dist = (entities[rid].position - core.scene.player_pos).length()
			if dist <= radius:
				res.append(rid)
	return res

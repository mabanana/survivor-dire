class_name CoreSignalBus

var core: CoreModel
var core_changed: Signal

func _init(core, core_changed):
	self.core = core
	self.core_changed = core_changed

func emit_core_changed(context, payload):
	var new_payload = payload_override(context, payload)
	core_changed.emit(context, new_payload)

func payload_override(context, payload):
	var new_payload = payload
	return new_payload

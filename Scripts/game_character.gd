class_name GameCharacter
extends CharacterBody2D

var rid: int
var entity_type: CoreModel.EntityType
var core: CoreModel
var core_changed: Signal

func bind(core, core_changed):
	self.core = core
	self.core_changed = core_changed
	
	core_changed.connect(_on_core_changed)
	
func _on_core_changed(context, payload):
	pass

func die():
	queue_free()

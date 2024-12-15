class_name HudController
extends Control

var core: CoreModel
var core_changed: Signal

@onready var hp_num: Label = %HpNum
@onready var xp_num: Label = %XpNum
@onready var kill_count: Label = %KillCount

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func bind(core: CoreModel, core_changed: Signal):
	self.core = core
	self.core_changed = core_changed
	
	core_changed.connect(_on_core_changed)

func _on_core_changed(context, payload):
	xp_num.text = str(core.progress.exp)
	hp_num.text = str(core.stats.hp)
	kill_count.text = str(core.progress.kill_count)

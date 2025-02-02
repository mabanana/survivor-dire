class_name HudController
extends Control

var core: CoreModel
var core_changed: Signal

@onready var volume_slider: HSlider = %VolumeSlider
@onready var hp_num: Label = %HpNum
@onready var xp_num: Label = %XpNum
@onready var combo: Label = %Combo
@onready var dmg_num: Label = %DmgNum
@onready var atk_speed: Label = %ASNum

@onready var inventory: TextureRect = %Inventory
@onready var pickup_popup: PackedScene = preload("res://Scenes/pickup_pop_up.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	volume_slider.value_changed.connect(_change_master_volume)
	volume_slider.drag_ended.connect(func(value_changed):
		volume_slider.release_focus()
		)

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
	combo.text = str(core.progress.combo)
	dmg_num.text = str(int(core.stats.attack_damage * core.stats.damage_amp))
	atk_speed.text = str(int(core.stats.attack_speed))
	
	if context == CoreModel.Context.loot_dropped:
		var new_pop: PickupPopup = pickup_popup.instantiate()
		new_pop.num = payload[CoreModel.PKey.amount]
		new_pop.position = inventory.position
		new_pop.modulate.a = 0.7
		var vert = inventory.get_rect().size.y
		var new_pos = position - Vector2(0, vert * randf_range(1.5, 4))
		inventory.add_child(new_pop)
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(new_pop, "position", new_pos, 0.6)
		tween.tween_property(new_pop, "modulate/a", 1, 0.3)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_callback(new_pop.queue_free)

func _change_master_volume(value):
	var db = -16 + value/100 * 16
	AudioServer.set_bus_volume_db(0, db)

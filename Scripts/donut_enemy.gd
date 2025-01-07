class_name DonutEnemy
extends EnemyCharacter

@onready var hole_sprite: Sprite2D = %ClickHitBox

func _ready():
	core_changed.connect(on_core_changed)

func on_core_changed(context, payload):
	if context == core.Context.mouse_button_pressed:
		var rect = hole_sprite.get_rect()
		rect.size = rect.size
		var rel_pos = to_local(payload[core.PKey.mouse_position])
		if rect.has_point(rel_pos):
			core.emit_changed(core.Context.donut_center_click, {
				core.PKey.target_rid : rid,
			})
			prints("Click detected on donut hole", rect, rel_pos)

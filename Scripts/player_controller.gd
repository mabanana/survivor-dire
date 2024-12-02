class_name PlayerController
extends GameCharacter

var attack_cd: Countdown
var spell_cd: Countdown
var rid_closest: int
var aim_cast: AimCast

var base_damage: int = 1# replace with some weapon/class system

func _ready() -> void:
	core.stats.attack_speed *= 4
	attack_cd = Countdown.new(1/core.stats.attack_speed)
	spell_cd = Countdown.new(core.stats.spell_cooldown)
	aim_cast = AimCast.new()
	add_child(aim_cast)

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var speed = core.stats.move_speed
	if direction:
		velocity = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)

	move_and_slide()

func _process(delta: float) -> void:
	for cd in [attack_cd, spell_cd]:
		var tick = cd.tick(delta)
		if tick <= 0:
			if cd == attack_cd:
				attack_cd.reset_cd()
				_attack([rid_closest])


func _on_core_changed(context, payload):
	if context == CoreModel.Context.mouse_button_pressed:
		if payload[CoreModel.PKey.input_action] == InputHandler.PlayerActions.AIM_ATTACK:
			var colliders = _get_colldiers(payload[CoreModel.PKey.mouse_position], core.stats.spell_radius)
			prints("colliders:", colliders)
			_attack(colliders)
	elif context == CoreModel.Context.map_update:
		_get_closest_enemy()

func _get_colldiers(mouse_pos, radius):
	print("mouse_pos", mouse_pos)
	return aim_cast.get_colldiers(mouse_pos - position, radius)

func _attack(rid_array):
	for i in range(len(rid_array)):
		if rid_array[i] and rid_array[i] in core.scene.entities:
			print("%s attacked %s for %s damage" % [
				core.scene.nodes[rid].name, 
				core.scene.nodes[rid_array[i]].name,
				core.stats.damage_amp * base_damage
				])
			core_changed.emit(CoreModel.Context.damage_started, 
			{
				core.PKey.num_targets: 1,
				core.PKey.amount : core.stats.damage_amp * base_damage,
				core.PKey.target_rid : [rid_array[i]],
				core.PKey.dealer_rid : rid,
				core.PKey.target_position : core.scene.entities[rid_array[i]].position,
			}) 


func _get_closest_enemy():
	var ents = core.scene.entities
	var dist_closest
	for ent_rid in ents.keys():
		if ent_rid == rid:
			continue
		var player_dist = (ents[ent_rid].position - position).length()
		if (!dist_closest or player_dist < dist_closest):
				if player_dist < core.stats.attack_range:
					dist_closest = player_dist
					rid_closest = ent_rid

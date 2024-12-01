class_name PlayerController
extends GameCharacter

var attack_cd: Countdown
var rid_closest: int

func _ready() -> void:
	attack_cd = Countdown.new(1/core.stats.attack_speed)

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
	var tick = attack_cd.tick(delta)
	if tick <= 0:
		attack_cd.reset_cd()
		_attack()
		print("attack!!")

func _attack():
	if rid_closest and rid_closest in core.scene.entities:
		core.scene.entities[rid_closest].hp -= core.stats.damage_amp*1

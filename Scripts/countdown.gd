class_name Countdown

var cd: float
var cd_start_value: float

func _init(cd_start_value: float):
	self.cd_start_value = cd_start_value

func tick(delta: float):
	if cd > 0:
		cd -= delta
	return cd
	
func reset_cd(new_cd = cd_start_value):
	cd = new_cd

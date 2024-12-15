class_name PickupPopup
extends HBoxContainer

var icon: Texture2D
var num: int

# Called when the node enters the scene tree for the first time.
func _ready():
	if num == 1:
		$NumAmount.hide()
		$X.hide()
	$NumAmount.text = str(num)
	if icon:
		$Icon.texture = icon


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

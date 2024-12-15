class_name InputHandler

var input_map
var scene

var core: CoreModel
var core_changed: Signal

static var DEFAULT_INPUT_MAP := {
	MouseButton.MOUSE_BUTTON_WHEEL_UP : PlayerActions.NEXT_WEAPON,
	MouseButton.MOUSE_BUTTON_WHEEL_DOWN : PlayerActions.PREV_WEAPON,
	MouseButton.MOUSE_BUTTON_LEFT: PlayerActions.AIM_ATTACK,
	Key.KEY_W : PlayerActions.MOVE_FORWARD,
	Key.KEY_A : PlayerActions.MOVE_LEFT,
	Key.KEY_S : PlayerActions.MOVE_BACKWARD,
	Key.KEY_D : PlayerActions.MOVE_RIGHT,
	Key.KEY_E : PlayerActions.INTERACT,
	Key.KEY_TAB : PlayerActions.NEXT_WEAPON,
	Key.KEY_ESCAPE : PlayerActions.ESC_MENU,
	Key.KEY_1 : PlayerActions.SELECT_SlOT_1,
	Key.KEY_2 : PlayerActions.SELECT_SlOT_2,
	Key.KEY_3 : PlayerActions.SELECT_SlOT_3,
	Key.KEY_4 : PlayerActions.SELECT_SlOT_4,
	Key.KEY_V : PlayerActions.NEXT_WEAPON,
	Key.KEY_X : PlayerActions.PREV_WEAPON,
}

# Enum for potential player actions
enum PlayerActions {
	NEXT_WEAPON,
	PREV_WEAPON,
	MOVE_FORWARD,
	MOVE_BACKWARD,
	MOVE_LEFT,
	MOVE_RIGHT,
	INTERACT,
	SELECT_SlOT_1,
	SELECT_SlOT_2,
	SELECT_SlOT_3,
	SELECT_SlOT_4,
	ESC_MENU, # Main pause menu
	INVENTORY, # Open inventory and other in game menus
	AIM_ATTACK,
}
 
func _init(scene):
	self.scene = scene
	input_map = DEFAULT_INPUT_MAP
	
func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index in input_map:
		var context
		if event.is_pressed() and !event.is_echo():
			context = CoreModel.Context.mouse_button_pressed
		elif event.is_released():
			context = CoreModel.Context.mouse_button_released
		else:
			print("ERROR: event mouse button that is neither pressed nor released detected")
			return
		core_changed.emit(context, {
				CoreModel.PKey.input_action : input_map[event.button_index], 
				CoreModel.PKey.input_as_text : event.as_text(),
				CoreModel.PKey.mouse_position: scene.get_global_mouse_position(),
				})
		prints("InputHandler: mouse button", "pressed" if event.is_pressed() else "released", event.as_text())
	elif event is InputEventKey and event.keycode in input_map:
		var context
		if event.is_pressed() and !event.is_echo():
			context = CoreModel.Context.key_input_pressed
		elif event.is_echo():
			# print("echo press event")
			return
		elif event.is_released():
			context = CoreModel.Context.key_input_released
		else:
			print("ERROR: event key press that is neither pressed nor released detected")
			return
		core_changed.emit(context, {
			CoreModel.PKey.input_action: input_map[event.keycode], 
			CoreModel.PKey.input_as_text : event.keycode
			})
		#prints("InputHandler: key", "pressed" if event.is_pressed() else "released", event.as_text())
	elif event is InputEventMouseMotion:
		core_changed.emit(CoreModel.Context.event_mouse_moved, {
			CoreModel.PKey.mouse_relative: event.relative
			})
		#prints("InputHandler: mouse moved", event.relative)
	else:
		print("InputHandler: unhandled input")


func bind(core: CoreModel, core_changed: Signal):
	self.core = core
	self.core_changed = core_changed

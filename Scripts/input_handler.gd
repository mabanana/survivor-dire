class_name InputHandler

var input_map

var core: CoreModel
var core_changed: Signal
var contexts

static var DEFAULT_INPUT_MAP := {
	MouseButton.MOUSE_BUTTON_WHEEL_UP : PlayerActions.NEXT_WEAPON,
	MouseButton.MOUSE_BUTTON_WHEEL_DOWN : PlayerActions.PREV_WEAPON,
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
}
 
func _init():
	input_map = DEFAULT_INPUT_MAP
	
func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index in input_map:
		var context
		if event.is_pressed() and !event.is_echo():
			context = contexts.event_input_pressed
		elif event.is_released():
			context = contexts.event_input_released
		else:
			print("ERROR: event mouse button that is neither pressed nor released detected")
			return
		core_changed.emit(context, {
				"action": input_map[event.button_index], 
				"button_index" : event.button_index
				})
	elif event is InputEventKey and event.keycode in input_map:
		var context
		if event.is_pressed() and !event.is_echo():
			context = contexts.event_input_pressed
		elif event.is_echo():
			# print("echo press event")
			return
		elif event.is_released():
			context = contexts.event_input_released
		else:
			print("ERROR: event key press that is neither pressed nor released detected")
			return
		core_changed.emit(context, {
			"action": input_map[event.keycode], 
			"key_code" : event.keycode
			})
	elif event is InputEventMouseMotion:
		core_changed.emit(contexts.event_mouse_moved, {
			"relative": event.relative
			})
	else:
		print("InputHandler: unhandled input")


func bind(core: CoreModel, core_changed: Signal):
	self.core = core
	self.core_changed = core_changed
	contexts = core.services.Context

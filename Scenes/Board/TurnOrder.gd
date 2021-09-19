extends Node2D


onready var itemListWindow = $ItemListWindow
onready var actionList := []
var _action_reference = {}


func _ready():
	## TODO: Remove this ready, it is just for testing
	var turnAction = TurnAction.new()
	turnAction.should_show_in_ui = false
	turnAction.id = "myid"
	_add_action(turnAction)
	_update_ui()


func _add_action(action: TurnAction):
	if typeof(action) != typeof(TurnAction):
		print("Action is not of type TurnAction!")
		return
	if action.id != "" and not action.id in _action_reference:
		_action_reference[action.id] = action
	actionList.append(
		action
	)


func _update_ui():
	itemListWindow.clear()
	for action in actionList:
		if action.should_show_in_ui:
			itemListWindow.add_item(action.name)

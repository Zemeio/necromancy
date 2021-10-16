extends Node2D


onready var itemListWindow = $ItemListWindow
onready var actionList := []
var _action_reference = {}


func _add_action(action: TurnAction):
	if typeof(action) != typeof(TurnAction):
		print("Action is not of type TurnAction!")
		return
	if action.id != "" and not action.id in _action_reference:
		_action_reference[action.id] = action
	actionList.append(
		action
	)


func addCharacterTurn(unit: Unit):
	var turnAction = TurnAction.new()
	turnAction.should_show_in_ui = true
	turnAction.turnType = TurnAction.TURN_TYPE_CHARACTER_TURN
	turnAction.name = unit.getName()
	turnAction.source = unit
	_add_action(turnAction)
	_update_ui()


func _update_ui():
	itemListWindow.clear()
	for action in actionList:
		if action.should_show_in_ui:
			itemListWindow.add_item(action.name)

extends Node2D


onready var itemListWindow = $ItemListWindow
onready var actionList := []
var _action_reference = {}

# _unit_attributes is a dictionary to keep track of attributes that only make
# sense on the turn order, such as wait. These attributes should be only used
# internally, and do not need to make sense out of this script.
var _unit_attributes := {}


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


func __calculate_random_initial_wait():
	# Initial wait should be between 50 and 100
	return (randi() % 50) + 51

func initialize(units):
	_calculate_turn_order(units)
	for unit in units:
		addCharacterTurn(unit)


func _calculate_turn_order(units: Array):
	_initialize_non_initialized_units(units)

	var remaining_units := units.duplicate(false)
	# Calculate next action
	var next_action: Array = _calculate_next_action(remaining_units)
	return next_action

	# Predict future actions
	# TODO: implement predict future actions

func _calculate_next_action(remaining_units):
	# Return units that can act now, in the order resolved by the tiebreaker
	var waits_per_speed = _calculate_waits_per_speed(remaining_units)
	var units_that_can_act = _find_units_that_can_act_now(waits_per_speed)
	units_that_can_act = _resolve_tiebreakers(units_that_can_act, waits_per_speed)
	return units_that_can_act

func _calculate_waits_per_speed(units):
	var smallest_tick = 100 # 100 is the biggest value of wait/speed
	for unit in units:
		var units_tick_until_0 = ceil(float(_unit_attributes[unit]["wait"]) / unit.get_speed())
		if units_tick_until_0 < smallest_tick:
			smallest_tick = units_tick_until_0
	
	var waits_per_speed := {}
	for unit in units:
		waits_per_speed[unit] = _unit_attributes[unit]["wait"] - (unit.get_speed()*smallest_tick)
	
	return waits_per_speed

func _find_units_that_can_act_now(waits_per_speed):
	var units_that_have_0_or_less_wait = []
	for unit in waits_per_speed:
		if waits_per_speed[unit] <= 0:
			units_that_have_0_or_less_wait.append(unit)
	return units_that_have_0_or_less_wait

func _resolve_tiebreaker1():
	pass

func _resolve_tiebreaker2():
	pass

func _resolve_tiebreakers(units_that_can_act: Array, waits_per_speed: Dictionary):
	if units_that_can_act.size() == 1: return units_that_can_act # No ties

	var final_order = []
	var groups = _resolve_tiebreaker1()
	for group in groups:
		if group.size() > 1:
			group = _resolve_tiebreaker2()
		final_order.append_array(group)

func _initialize_non_initialized_units(units):

	for unit in units:
		if not unit in _unit_attributes:
			_unit_attributes[unit] = {
					wait = __calculate_random_initial_wait()
				}

func _update_ui():
	itemListWindow.clear()
	for action in actionList:
		if action.should_show_in_ui:
			itemListWindow.add_item(action.name)

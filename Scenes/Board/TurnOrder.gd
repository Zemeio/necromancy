extends Node2D


onready var itemListWindow = $ItemListWindow
onready var actionList := []
var _action_reference = {}

# _unit_attributes is a dictionary to keep track of attributes that only make
# sense on the turn order, such as wait. These attributes should be only used
# internally, and do not need to make sense out of this script.
var _unit_attributes := {}


func _init():
	randomize()


const IS_DEBUG := true

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
	var unit_turns = _calculate_turn_order(units)
	for unit in unit_turns:
		addCharacterTurn(unit)


func _calculate_turn_order(units: Array) -> Array:
	_initialize_non_initialized_units(units)

	var remaining_units := units.duplicate(false)
	var turn_order := []
	while remaining_units.size() > 1:
		var waits_per_speed = _calculate_waits_per_speed(remaining_units, _unit_attributes)
		var next_action: Array = _calculate_next_action(remaining_units, waits_per_speed)
		for action in next_action:
			turn_order.append(action)
			remaining_units.remove(remaining_units.find(action))
	turn_order += remaining_units
	return turn_order

func _calculate_next_action(remaining_units, waits_per_speed):
	# Return units that can act now, in the order resolved by the tiebreaker
	var units_that_can_act = _find_units_that_can_act_now(waits_per_speed)
	units_that_can_act = _resolve_tiebreakers(units_that_can_act, waits_per_speed)
	return units_that_can_act

func _calculate_waits_per_speed(units, attrs):
	var smallest_tick = 100 # 100 is the biggest value of wait/speed
	for unit in units:
		var units_tick_until_0 = ceil(float(attrs[unit]["wait"]) / unit.get_speed())
		if units_tick_until_0 < smallest_tick:
			smallest_tick = units_tick_until_0
	
	var waits_per_speed := {}
	for unit in units:
		waits_per_speed[unit] = attrs[unit]["wait"] - (unit.get_speed()*smallest_tick)
	
	return waits_per_speed

func _find_units_that_can_act_now(waits_per_speed):
	var units_that_have_0_or_less_wait = []
	for unit in waits_per_speed:
		if waits_per_speed[unit] <= 0:
			units_that_have_0_or_less_wait.append(unit)
	return units_that_have_0_or_less_wait

func _resolve_tiebreakers(units_that_can_act: Array, waits_per_speed: Dictionary):
	if units_that_can_act.size() == 1: return units_that_can_act # No ties

	var tiebreakers = TiebreakerWait.new()\
						.otherwise(TiebreakerSpeed.new())\
						.otherwise(TiebreakerFinal.new())

	var units_order_by_tiebreak: Array = tiebreakers.resolve(units_that_can_act, waits_per_speed)
	return units_order_by_tiebreak

func _initialize_non_initialized_units(units):
	for unit in units:
		if not unit in _unit_attributes:
			_unit_attributes[unit] = {
					wait = __calculate_random_initial_wait()
				}
			if IS_DEBUG:
				_unit_attributes[unit] = {
					wait = unit.UnitInfo._debug_wait
				}

func _update_ui():
	itemListWindow.clear()
	for action in actionList:
		if action.should_show_in_ui:
			itemListWindow.add_item(action.name)

class Tiebreaker:
	var next_method: Tiebreaker = null
	
	func set_last(next_method: Tiebreaker):
		if self.next_method == null:
			self.next_method = next_method
		else:
			self.next_method.otherwise(next_method)
	
	func otherwise(next_method: Tiebreaker) -> Tiebreaker:
		self.set_last(next_method)
		return self

	func resolve(group, waits_per_speed):
		if group.size() == 1: return group # Nothing to resolve
		var result_groups: Array = self.__resolve_group(group, waits_per_speed)

		var final_result := []
		for resolved_group in result_groups:
			if resolved_group.size() > 1 and next_method != null:
				resolved_group = self.next_method.resolve(resolved_group, waits_per_speed) # needs further resolution
			final_result.append_array(resolved_group)
		return final_result

	func __resolve_group(group, waits_per_speed):
		var grouped_per_waits: Dictionary = self._group_by(group, waits_per_speed)
		var resolved_groups := []
		var keys: Array = grouped_per_waits.keys()
		keys.sort()
		for wait in keys:
			resolved_groups.append(grouped_per_waits[wait])
		return resolved_groups
		
	func _group_by(group, waits_per_speed) -> Dictionary:
		# Abstract method
		return {}

class TiebreakerWait extends Tiebreaker:

	func _group_by(group, waits_per_speed) -> Dictionary:
		var grouped_per_waits := {}
		for unit in group:
			var unit_wait = waits_per_speed[unit]
			if not unit_wait in grouped_per_waits:
				grouped_per_waits[unit_wait] = []
			grouped_per_waits[unit_wait].append(unit)
		return grouped_per_waits


class TiebreakerSpeed extends Tiebreaker:

	func _group_by(group, waits_per_speed):
		var grouped_per_speed := {}
		for unit in group:
			var unit_speed = -unit.get_speed() # Uses negative because priority is from top to bottom
			if not unit_speed in grouped_per_speed:
				grouped_per_speed[unit_speed] = [] 
			grouped_per_speed[unit_speed].append(unit)
		return grouped_per_speed

class TiebreakerFinal extends Tiebreaker:
	
	func resolve(group, waits_per_speed):
		return group
